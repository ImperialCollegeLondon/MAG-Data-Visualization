classdef (TestTags = ["Unit", "Parallel"]) tSelect < matlab.unittest.TestCase
% TSELECT Unit tests for "mag.graphics.operation.Select" class.

    methods (Test)

        % Test that "apply" method selects correct values.
        function apply(testCase)

            % Set up.
            select = mag.graphics.operation.Select(Variables = ["B", "C", "A"]);

            data = table((1:10)', (11:20)', (21:30)', VariableNames = ["A", "B", "C"]);
            expectedValue = [data.B, data.C, data.A];

            % Exercise.
            actualValue = select.apply(data);

            % Verify.
            testCase.verifyEqual(actualValue, expectedValue, "Selection result should be as expected.");
        end
    end
end
