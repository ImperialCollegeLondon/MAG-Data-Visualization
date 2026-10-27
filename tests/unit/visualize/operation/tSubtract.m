classdef (TestTags = ["Unit", "Parallel"]) tSubtract < matlab.unittest.TestCase
% TSUBTRACT Unit tests for "mag.graphics.operation.Subtract" class.

    methods (Test)

        % Test that "apply" method subtracts "subtrahend" from "minuend".
        function apply(testCase)

            % Set up.
            subtract = mag.graphics.operation.Subtract(Minuend = "A", Subtrahend = "B");

            data = table((1:10)', (11:20)', VariableNames = ["A", "B"]);
            expectedValue = data.A - data.B;

            % Exercise.
            actualValue = subtract.apply(data);

            % Verify.
            testCase.verifyEqual(actualValue, expectedValue, "Subtraction result should be as expected.");
        end
    end
end
