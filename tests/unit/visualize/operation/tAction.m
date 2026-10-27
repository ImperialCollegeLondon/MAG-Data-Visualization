classdef (TestTags = ["Unit", "Parallel"]) tAction < matlab.unittest.TestCase
% TACTION Unit tests for "mag.graphics.operation.Action" class.

    methods (Test)

        % Test that "applyAll" method combines partial results correctly.
        function applyAll(testCase)

            % Set up.
            select = mag.graphics.operation.Select(Variables = ["B", "C", "A"]);
            subtract = mag.graphics.operation.Subtract(Minuend = "C", Subtrahend = "A");

            actions = [select, subtract];

            data = table((1:10)', (11:20)', (21:30)', VariableNames = ["A", "B", "C"]);
            expectedValue = [data.B, data.C, data.A, data.C - data.A];

            % Exercise.
            actualValue = actions.applyAll(data);

            % Verify.
            testCase.verifyEqual(actualValue, expectedValue, "Actions result should be as expected.");
        end
    end
end
