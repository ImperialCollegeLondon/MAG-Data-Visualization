classdef BackgroundTask < mag.mixin.SetGet
% BACKGROUNDTASK Run a function in the background, without blocking MATLAB.
%
%   The function first runs on a thread-based worker of the background
%   pool. If it uses functionality not supported on threads (e.g., MEX
%   files), it runs again in the first available fallback environment.
%   The environment required by each task name is remembered, so that
%   later tasks with the same name start in the correct environment.

    events
        % COMPLETED Task succeeded, failed or was cancelled.
        Completed
    end

    properties
        % NAME Name of task, used to remember required environment.
        Name (1, 1) string = ""
        % DESCRIPTION Description of task, shown when blocking MATLAB.
        Description (1, 1) string = "Running..."
        % ENVIRONMENT Environment to run in. If empty, it is selected
        % automatically.
        Environment mag.app.internal.ExecutionEnvironment {mustBeScalarOrEmpty}
        % FALLBACK Environments to try, in order, if function is not
        % supported on threads.
        Fallback (1, :) mag.app.internal.ExecutionEnvironment = [mag.app.internal.ExecutionEnvironment.Process, mag.app.internal.ExecutionEnvironment.Foreground]
        % SUCCESSFCN Function called with task outputs on success. If it
        % errors, the task fails.
        SuccessFcn function_handle {mustBeScalarOrEmpty}
        % BLOCKINGFCN Function called with a message before blocking
        % MATLAB. Its output is deleted when blocking ends.
        BlockingFcn function_handle {mustBeScalarOrEmpty}
    end

    properties (SetAccess = private)
        % FUNCTION Function to run.
        Function (1, 1) function_handle = @() []
        % NUMOUTPUTS Number of function outputs.
        NumOutputs (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
        % ARGUMENTS Function input arguments.
        Arguments (1, :) cell = {}
        % CURRENTENVIRONMENT Environment task is running, or ran, in.
        CurrentEnvironment mag.app.internal.ExecutionEnvironment {mustBeScalarOrEmpty}
        % STATE State of task.
        State (1, 1) mag.app.internal.TaskState = mag.app.internal.TaskState.Pending
        % OUTPUTS Function outputs, if succeeded.
        Outputs (1, :) cell = {}
        % ERROR Error thrown by function, if failed.
        Error MException {mustBeScalarOrEmpty}
        % DIARY Text output of function, when run in background.
        Diary (1, 1) string = ""
        % STARTTIME Time task started.
        StartTime (1, 1) datetime = NaT()
        % FINISHTIME Time task completed.
        FinishTime (1, 1) datetime = NaT()
    end

    properties (Dependent, SetAccess = private)
        % ISRUNNING Logical denoting whether task is running.
        IsRunning (1, 1) logical
        % DURATION Duration of task.
        Duration (1, 1) duration
    end

    properties (Access = private)
        % FUTURE Future of function running in background.
        Future parallel.Future {mustBeScalarOrEmpty}
    end

    methods

        function this = BackgroundTask(fcn, numOutputs, args, options)

            arguments
                fcn (1, 1) function_handle
                numOutputs (1, 1) double {mustBeInteger, mustBeNonnegative} = 0
                args (1, :) cell = {}
                options.?mag.app.internal.BackgroundTask
            end

            this.Function = fcn;
            this.NumOutputs = numOutputs;
            this.Arguments = args;

            this.assignProperties(options);

            if strlength(this.Name) == 0
                this.Name = func2str(fcn);
            end
        end

        function delete(this)

            if this.IsRunning && ~isempty(this.Future)
                this.Future.cancel();
            end
        end

        function value = get.IsRunning(this)
            value = this.State == mag.app.internal.TaskState.Running;
        end

        function value = get.Duration(this)

            if this.State.isDone()
                value = this.FinishTime - this.StartTime;
            elseif this.IsRunning
                value = datetime("now") - this.StartTime;
            else
                value = seconds(0);
            end
        end

        function start(this)
        % START Start task. If running in the foreground, it returns only
        % once the task is completed.

            if this.State ~= mag.app.internal.TaskState.Pending
                error("mag:app:TaskAlreadyStarted", "Task ""%s"" has already been started.", this.Name);
            end

            this.StartTime = datetime("now");
            this.State = mag.app.internal.TaskState.Running;

            if isempty(this.Environment)
                environments = this.selectEnvironments();
            else
                environments = this.Environment;
            end

            this.submit(environments);
        end

        function cancel(this)
        % CANCEL Cancel task, if running.

            if ~this.IsRunning
                return;
            end

            if ~isempty(this.Future)
                this.Future.cancel();
            end

            this.complete(mag.app.internal.TaskState.Cancelled);
        end

        function completed = wait(this, timeout)
        % WAIT Wait for task to complete, or until timeout (in seconds) is
        % reached.

            arguments (Input)
                this (1, 1) mag.app.internal.BackgroundTask
                timeout (1, 1) double {mustBePositive} = Inf
            end

            arguments (Output)
                completed (1, 1) logical
            end

            deadline = tic();

            while this.IsRunning && (toc(deadline) < timeout)

                if ~isempty(this.Future)
                    this.Future.wait("finished", min(0.1, max(0, timeout - toc(deadline))));
                end

                % Process completion callbacks.
                drawnow();
            end

            completed = ~this.IsRunning;
        end
    end

    methods (Static, Hidden)

        function environment = getRequiredEnvironment(name)
        % GETREQUIREDENVIRONMENT Get environment previously required by
        % tasks with the same name, or empty if unknown.

            environment = mag.app.internal.BackgroundTask.manageRequiredEnvironments("get", name);
        end

        function clearRequiredEnvironments()
        % CLEARREQUIREDENVIRONMENTS Forget environments required by
        % previous tasks.

            mag.app.internal.BackgroundTask.manageRequiredEnvironments("clear");
        end
    end

    methods (Access = private)

        function environments = selectEnvironments(this)
        % SELECTENVIRONMENTS Select environments to try, in order.

            if ~mag.internal.ToolboxSettings.getSettingValue("BackgroundProcessing")
                environments = mag.app.internal.ExecutionEnvironment.Foreground;
                return;
            end

            required = this.getRequiredEnvironment(this.Name);

            if isempty(required)
                environments = [mag.app.internal.ExecutionEnvironment.Thread, this.Fallback];
            else
                environments = [required, this.Fallback(this.Fallback ~= required)];
            end
        end

        function submit(this, environments)
        % SUBMIT Run function in first environment that is available.

            for e = 1:numel(environments)

                environment = environments(e);

                if environment == mag.app.internal.ExecutionEnvironment.Foreground

                    this.CurrentEnvironment = environment;
                    this.runInForeground();
                    return;
                end

                try
                    pool = this.getPool(environment);
                catch
                    continue;
                end

                this.CurrentEnvironment = environment;

                this.Future = parfeval(pool, this.Function, this.NumOutputs, this.Arguments{:});
                this.Future.afterAll(@(future) mag.app.internal.BackgroundTask.onFutureCompleted(this, future, environments(e + 1:end)), 0, PassFuture = true);

                return;
            end

            this.Error = MException("mag:app:NoEnvironmentAvailable", "No environment available to run task ""%s"".", this.Name);
            this.complete(mag.app.internal.TaskState.Failed);
        end

        function runInForeground(this)

            unblock = this.block(this.Description);
            outputs = cell(1, this.NumOutputs);

            try
                [outputs{:}] = this.Function(this.Arguments{:});
            catch exception

                delete(unblock);

                this.Error = exception;
                this.complete(mag.app.internal.TaskState.Failed);
                return;
            end

            delete(unblock);
            this.succeed(outputs);
        end

        function unblock = block(this, message)
        % BLOCK Notify that MATLAB is about to be blocked. Delete returned
        % object to notify that blocking ended.

            arguments (Input)
                this (1, 1) mag.app.internal.BackgroundTask
                message (1, 1) string
            end

            arguments (Output)
                unblock (1, 1) onCleanup
            end

            if isempty(this.BlockingFcn)
                unblockFcn = [];
            else
                unblockFcn = this.BlockingFcn(message);
            end

            unblock = onCleanup(@() delete(unblockFcn));
        end

        function pool = getPool(this, environment)

            switch environment
                case mag.app.internal.ExecutionEnvironment.Thread
                    pool = backgroundPool();
                case mag.app.internal.ExecutionEnvironment.Process

                    if ~canUseParallelPool()
                        error("mag:app:ProcessPoolUnavailable", "Parallel Computing Toolbox is not available.");
                    end

                    pool = gcp("nocreate");

                    if isempty(pool)

                        unblock = this.block("Starting background worker..."); %#ok<NASGU>
                        pool = parpool("Processes", 1);
                    elseif isa(pool, "parallel.ThreadPool")
                        error("mag:app:ProcessPoolUnavailable", "Current parallel pool is not process-based.");
                    end
                otherwise
                    error("mag:app:UnsupportedEnvironment", "Unsupported environment ""%s"".", environment);
            end
        end

        function futureCompleted(this, future, fallback)

            % Ignore results from cancelled or superseded futures.
            if ~this.IsRunning || isempty(this.Future) || (future.ID ~= this.Future.ID)
                return;
            end

            this.Diary = this.Diary + string(future.Diary);

            if isempty(future.Error)

                outputs = cell(1, this.NumOutputs);
                [outputs{:}] = future.fetchOutputs();

                this.succeed(outputs);
                return;
            end

            exception = this.unwrapException(future.Error);

            % Retry in the next environment, if function is not supported
            % on threads.
            if (this.CurrentEnvironment == mag.app.internal.ExecutionEnvironment.Thread) && ...
                    this.isUnsupportedOnThreads(exception) && ~isempty(fallback)

                this.Future = parallel.FevalFuture.empty();
                this.submit(fallback);

                if this.CurrentEnvironment ~= mag.app.internal.ExecutionEnvironment.Thread
                    this.manageRequiredEnvironments("set", this.Name, this.CurrentEnvironment);
                end

                return;
            end

            this.Error = exception;
            this.complete(mag.app.internal.TaskState.Failed);
        end

        function succeed(this, outputs)

            if ~isempty(this.SuccessFcn)

                try
                    this.SuccessFcn(outputs{:});
                catch exception

                    this.Error = exception;
                    this.complete(mag.app.internal.TaskState.Failed);
                    return;
                end
            end

            this.Outputs = outputs;
            this.complete(mag.app.internal.TaskState.Succeeded);
        end

        function complete(this, state)

            this.State = state;
            this.FinishTime = datetime("now");

            this.notify("Completed");
        end
    end

    methods (Static, Access = private)

        function onFutureCompleted(task, future, fallback)

            % Task may have been deleted in the meantime.
            if isvalid(task)
                task.futureCompleted(future, fallback);
            end
        end

        function exception = unwrapException(exception)
        % UNWRAPEXCEPTION Retrieve original exception from worker, so that
        % stack refers to the source of the error.

            if isa(exception, "ParallelException") && ~isempty(exception.remotecause)
                exception = exception.remotecause{1};
            end
        end

        function unsupported = isUnsupportedOnThreads(exception)
        % ISUNSUPPORTEDONTHREADS Logical denoting whether exception, or any
        % of its causes, is due to functionality not supported on threads.

            unsupported = startsWith(exception.identifier, "parallel:threadpool:");

            for c = 1:numel(exception.cause)

                if unsupported
                    return;
                end

                unsupported = mag.app.internal.BackgroundTask.isUnsupportedOnThreads(exception.cause{c});
            end
        end

        function environment = manageRequiredEnvironments(action, name, environment)

            arguments
                action (1, 1) string {mustBeMember(action, ["get", "set", "clear"])}
                name (1, 1) string = ""
                environment mag.app.internal.ExecutionEnvironment {mustBeScalarOrEmpty} = mag.app.internal.ExecutionEnvironment.empty()
            end

            persistent requiredEnvironments

            if isempty(requiredEnvironments) || (action == "clear")
                requiredEnvironments = dictionary(string.empty(), mag.app.internal.ExecutionEnvironment.empty());
            end

            switch action
                case "get"

                    if requiredEnvironments.isKey(name)
                        environment = requiredEnvironments(name);
                    else
                        environment = mag.app.internal.ExecutionEnvironment.empty();
                    end
                case "set"
                    requiredEnvironments(name) = environment;
            end
        end
    end
end
