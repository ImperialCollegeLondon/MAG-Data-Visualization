classdef tBackgroundTask < matlab.unittest.TestCase
% TBACKGROUNDTASK Unit tests for "mag.app.internal.BackgroundTask" class.

    properties (Constant, Access = private)
        Timeout (1, 1) double = 60
    end

    properties (Access = private)
        NumCompletedEvents (1, 1) double = 0
        LogEntries (1, :) string = string.empty()
    end

    methods (TestMethodSetup)

        function clearRequiredEnvironments(testCase)

            mag.app.internal.BackgroundTask.clearRequiredEnvironments();
            testCase.addTeardown(@() mag.app.internal.BackgroundTask.clearRequiredEnvironments());
        end

        function enableBackgroundProcessing(testCase)
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", true));
        end
    end

    methods (Test)

        % Test that task runs on thread-based worker by default, without
        % blocking MATLAB.
        function start_thread(testCase)

            % Set up.
            task = testCase.createTaskWithListener(@(x) 2 * x, 1, {21});

            % Exercise.
            task.start();

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Running, "Task should be running.");
            testCase.verifyTrue(task.IsRunning, "Task should be running.");
            testCase.verifyEqual(task.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Thread, "Task should run on thread.");

            testCase.verifyTrue(task.wait(testCase.Timeout), "Task should complete.");

            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");
            testCase.verifyEqual(task.Outputs, {42}, "Task outputs should match expectation.");
            testCase.verifyEmpty(task.Error, "Task should have no error.");
            testCase.verifyGreaterThanOrEqual(task.Duration, seconds(0), "Task duration should be set.");
            testCase.verifyEqual(testCase.NumCompletedEvents, 1, "Completed event should be triggered once.");
        end

        % Test that task runs in the foreground, if requested.
        function start_foreground(testCase)

            % Set up.
            task = testCase.createTaskWithListener(@(x) 2 * x, 1, {21}, Environment = "Foreground");

            % Exercise.
            task.start();

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should complete before returning.");
            testCase.verifyEqual(task.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Foreground, "Task should run in the foreground.");
            testCase.verifyEqual(task.Outputs, {42}, "Task outputs should match expectation.");
            testCase.verifyEqual(testCase.NumCompletedEvents, 1, "Completed event should be triggered once.");
        end

        % Test that task runs in the foreground when background processing
        % is disabled.
        function start_backgroundProcessingDisabled(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", false));

            task = mag.app.internal.BackgroundTask(@() 1, 1);

            % Exercise.
            task.start();

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should complete before returning.");
            testCase.verifyEqual(task.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Foreground, "Task should run in the foreground.");
        end

        % Test that blocking function is called when running in the
        % foreground, and released afterwards.
        function start_foregroundBlocking(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() testCase.addLogEntry("run"), 0, {}, Environment = "Foreground", Description = "Testing...", ...
                BlockingFcn = @(message) onCleanup(@() testCase.addLogEntry("unblock: " + message)));

            % Exercise.
            testCase.addLogEntry("start");
            task.start();

            % Verify.
            testCase.verifyEqual(testCase.LogEntries, ["start", "run", "unblock: Testing..."], "Blocking should surround foreground execution.");
        end

        % Test that task cannot be started twice.
        function start_alreadyStarted(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() 1, 1, {}, Environment = "Foreground");
            task.start();

            % Exercise and verify.
            testCase.verifyError(@() task.start(), "mag:app:TaskAlreadyStarted", "Error should be thrown when starting task twice.");
        end

        % Test that errors on worker are captured with the original
        % exception.
        function error_thread(testCase)

            % Set up.
            task = testCase.createTaskWithListener(@() error("mag:test:Failure", "Something failed."), 0);

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.assertNotEmpty(task.Error, "Task error should be set.");
            testCase.verifyEqual(task.Error.identifier, 'mag:test:Failure', "Original error identifier should be kept.");
            testCase.verifyNotEmpty(task.Error.stack, "Original error stack should be kept.");
            testCase.verifyEqual(testCase.NumCompletedEvents, 1, "Completed event should be triggered once.");
        end

        % Test that errors in the foreground are captured.
        function error_foreground(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() error("mag:test:Failure", "Something failed."), 0, {}, Environment = "Foreground");

            % Exercise.
            task.start();

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.verifyEqual(task.Error.identifier, 'mag:test:Failure', "Error identifier should match expectation.");
        end

        % Test that success function is called with task outputs.
        function successFcn(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() deal(1, 2), 2, {}, SuccessFcn = @(a, b) testCase.addLogEntry(compose("%d-%d", a, b)));

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");
            testCase.verifyEqual(testCase.LogEntries, "1-2", "Success function should be called with outputs.");
        end

        % Test that task fails if success function errors.
        function successFcn_error(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() 1, 1, {}, SuccessFcn = @(~) error("mag:test:Failure", "Something failed."));

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.verifyEqual(task.Error.identifier, 'mag:test:Failure', "Error identifier should match expectation.");
            testCase.verifyEmpty(task.Outputs, "Outputs should not be set.");
        end

        % Test that running task can be cancelled.
        function cancel(testCase)

            % Set up.
            task = testCase.createTaskWithListener(@() pause(30), 0);
            task.start();

            % Exercise.
            task.cancel();

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Cancelled, "Task should be cancelled.");
            testCase.verifyFalse(task.IsRunning, "Task should not be running.");
            testCase.verifyTrue(task.wait(testCase.Timeout), "Waiting on cancelled task should return immediately.");

            % Process any pending callbacks.
            drawnow();
            testCase.verifyEqual(testCase.NumCompletedEvents, 1, "Completed event should be triggered once.");
        end

        % Test that cancelling a completed task has no effect.
        function cancel_completed(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() 1, 1, {}, Environment = "Foreground");
            task.start();

            % Exercise.
            task.cancel();

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should still be successful.");
        end

        % Test that waiting returns false when timeout is reached.
        function wait_timeout(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() pause(30), 0);
            task.start();

            testCase.addTeardown(@() task.cancel());

            % Exercise.
            completed = task.wait(0.5);

            % Verify.
            testCase.verifyFalse(completed, "Wait should time out.");
            testCase.verifyTrue(task.IsRunning, "Task should still be running.");
        end

        % Test that text output and warnings from worker are captured.
        function diary(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() tBackgroundTask.printAndWarn(), 0);

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");
            testCase.verifySubstring(task.Diary, "Some output.", "Text output should be captured.");
            testCase.verifySubstring(task.Diary, "Some warning.", "Warnings should be captured.");
        end

        % Test that functions not supported on threads fall back to the
        % next environment, which is then remembered.
        function fallback_unsupportedOnThread(testCase)

            % Set up.
            name = "fallbackTest";
            task = testCase.createTaskWithListener(@() tBackgroundTask.unsupportedOnThread(), 1, {}, Name = name, Fallback = "Foreground");

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed after fallback.");
            testCase.verifyEqual(task.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Foreground, "Task should fall back to foreground.");
            testCase.verifyEqual(task.Outputs, {2}, "Task outputs should match expectation.");
            testCase.verifyEqual(testCase.NumCompletedEvents, 1, "Completed event should be triggered once.");

            testCase.verifyEqual(mag.app.internal.BackgroundTask.getRequiredEnvironment(name), mag.app.internal.ExecutionEnvironment.Foreground, ...
                "Required environment should be remembered.");

            % Verify that next task starts directly in required environment.
            nextTask = mag.app.internal.BackgroundTask(@() tBackgroundTask.unsupportedOnThread(), 1, {}, Name = name, Fallback = "Foreground");
            nextTask.start();

            testCase.verifyEqual(nextTask.State, mag.app.internal.TaskState.Succeeded, "Next task should complete before returning.");
            testCase.verifyEqual(nextTask.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Foreground, "Next task should run in the foreground.");
        end

        % Test that task fails if function is not supported on threads and
        % no fallback is allowed.
        function fallback_none(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() tBackgroundTask.unsupportedOnThread(), 1, {}, Fallback = mag.app.internal.ExecutionEnvironment.empty());

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.verifyTrue(startsWith(task.Error.identifier, "parallel:threadpool:"), "Error should be due to thread limitations.");
        end

        % Test that other errors on threads do not trigger fallback.
        function fallback_otherError(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() error("mag:test:Failure", "Something failed."), 0, {}, Fallback = "Foreground");

            % Exercise.
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.verifyEqual(task.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Thread, "Task should not fall back.");
            testCase.verifyEmpty(mag.app.internal.BackgroundTask.getRequiredEnvironment(task.Name), "No environment should be remembered.");
        end

        % Test that functions not supported on threads run on a
        % process-based worker, if available.
        function fallback_process(testCase)

            % Set up.
            testCase.assumeTrue(canUseParallelPool(), "Parallel Computing Toolbox not available. Test skipped.");
            testCase.assumeEmpty(gcp("nocreate"), "Parallel pool already running. Test skipped.");

            testCase.addTeardown(@() delete(gcp("nocreate")));

            task = mag.app.internal.BackgroundTask(@() tBackgroundTask.unsupportedOnThread(), 1);

            % Exercise.
            task.start();
            task.wait(300);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed after fallback.");
            testCase.verifyEqual(task.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Process, "Task should fall back to process.");
            testCase.verifyEqual(task.Outputs, {2}, "Task outputs should match expectation.");
        end

        % Test that deleting a running task cancels it.
        function delete_running(testCase)

            % Set up.
            task = mag.app.internal.BackgroundTask(@() pause(30), 0);
            task.start();

            % Exercise and verify.
            testCase.verifyWarningFree(@() delete(task), "Deleting running task should not warn.");
            drawnow();
        end
    end

    methods (Access = private)

        function task = createTaskWithListener(testCase, varargin)

            testCase.NumCompletedEvents = 0;

            task = mag.app.internal.BackgroundTask(varargin{:});
            task.addlistener("Completed", @(~, ~) testCase.incrementCompletedEvents());
        end

        function addLogEntry(testCase, entry)
            testCase.LogEntries(end + 1) = entry;
        end

        function incrementCompletedEvents(testCase)
            testCase.NumCompletedEvents = testCase.NumCompletedEvents + 1;
        end
    end

    methods (Static, Access = private)

        function printAndWarn()

            fprintf("Some output.\n");
            warning("mag:test:Warning", "Some warning.");
        end

        function value = unsupportedOnThread()
            value = evalin("base", "1 + 1"); %#ok<EVALIN>
        end
    end
end
