classdef (TestTags = ["Unit", "Parallel"]) tConvert < matlab.unittest.TestCase
% TCONVERT Unit tests for "mag.graphics.operation.Convert" class.

    methods (Test)

        % Test that "apply" method converts values correctly.
        function apply(testCase)

            % Set up.
            convert = mag.graphics.operation.Convert(Conversion = @(x) times(x, 2));

            data = [(1:10)', (11:20)', (21:30)'];
            expectedValue = 2 * data;

            % Exercise.
            actualValue = convert.apply(data);

            % Verify.
            testCase.verifyEqual(actualValue, expectedValue, "Converted result should be as expected.");
        end
    end
end
