classdef ExecutionEnvironment
% EXECUTIONENVIRONMENT Environments where background tasks can run.

    enumeration
        % THREAD Thread-based worker of background pool.
        Thread
        % PROCESS Process-based worker of parallel pool.
        Process
        % FOREGROUND MATLAB client, blocking execution.
        Foreground
    end

    methods

        function value = isBackground(this)
        % ISBACKGROUND Logical denoting whether environment does not block
        % MATLAB.
            value = this ~= mag.app.internal.ExecutionEnvironment.Foreground;
        end
    end
end
