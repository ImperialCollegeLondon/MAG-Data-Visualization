classdef TaskState
% TASKSTATE State of background task.

    enumeration
        % PENDING Task created but not started.
        Pending
        % RUNNING Task running.
        Running
        % SUCCEEDED Task completed successfully.
        Succeeded
        % FAILED Task completed with an error.
        Failed
        % CANCELLED Task cancelled before completion.
        Cancelled
    end

    methods

        function value = isDone(this)
        % ISDONE Logical denoting whether task is completed.
            value = ismember(this, [mag.app.internal.TaskState.Succeeded, mag.app.internal.TaskState.Failed, mag.app.internal.TaskState.Cancelled]);
        end
    end
end
