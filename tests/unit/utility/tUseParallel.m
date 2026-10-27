classdef (TestTags = "Unit") tUseParallel < matlab.unittest.TestCase
% TUSEPARALLEL Unit tests for "mag.internal.useParallel" function.

    methods (Test)

        % Test that "mag.internal.useParallel" returns "false" when no
        % parallel pool is set up.
        function noParallelPool(testCase)

            testCase.assumeTrue(~canUseParallelPool() || isempty(gcp("nocreate")), "Parallel pool already running. Test skipped.");

            testCase.verifyFalse(mag.internal.useParallel(), "Parallel Computing Toolbox should not be used if no parallel pool is running.");
        end

        % Test that "mag.internal.useParallel" returns "false" when
        % Parallel Computing Toolbox is not installed.
        function noParallelToolbox(testCase)

            license("test", "Distrib_Computing_Toolbox", "disable");
            testCase.addTeardown(@() license("test", "Distrib_Computing_Toolbox", "enable"));

            testCase.verifyFalse(mag.internal.useParallel(), "Parallel Computing Toolbox should not be used if it is not installed.");
        end
    end
end
