classdef tStatus < matlab.unittest.TestCase
% TSTATUS Unit tests for "mag.health.Status" class.

    methods (Test)

        function getWorst_pass(testCase)

            % Set up.
            status = [mag.health.Status.Pass, mag.health.Status.Pass, mag.health.Status.Pass];

            % Exercise.
            worstStatus = status.getWorst();

            % Verify.
            testCase.verifyEqual(worstStatus, mag.health.Status.Pass, "Worst status should be ""Pass"".");
        end

        function getWorst_borderline(testCase)

            % Set up.
            status = [mag.health.Status.Pass, mag.health.Status.Borderline, mag.health.Status.Pass];

            % Exercise.
            worstStatus = status.getWorst();

            % Verify.
            testCase.verifyEqual(worstStatus, mag.health.Status.Borderline, "Worst status should be ""Borderline"".");
        end

        function getWorst_fail(testCase)

            % Set up.
            status = [mag.health.Status.Pass, mag.health.Status.Fail, mag.health.Status.Pass];

            % Exercise.
            worstStatus = status.getWorst();

            % Verify.
            testCase.verifyEqual(worstStatus, mag.health.Status.Fail, "Worst status should be ""Fail"".");
        end

        function getWorst_fail_withIncomplete(testCase)

            % Set up.
            status = [mag.health.Status.Pass, mag.health.Status.Fail, mag.health.Status.Incomplete];

            % Exercise.
            worstStatus = status.getWorst();

            % Verify.
            testCase.verifyEqual(worstStatus, mag.health.Status.Fail, "Worst status should be ""Fail"".");
        end
    end
end
