classdef (TestTags = ["Unit", "Parallel"]) tMustMatchRegex < matlab.unittest.TestCase
% TMUSTMATCHREGEX Unit tests for "mag.validator.mustMatchRegex" function.

    methods (Test)

        % Test that no error is thrown when value matches regex.
        function mustMatchRegex(~)

            % Set up.
            value = "This is a value.";
            pattern = "This is a \w+\.";

            % Exercise and verify.
            mag.validator.mustMatchRegex(value, pattern);
        end

        % Test that no error is thrown when value is empty.
        function mustMatchRegex_empty(~)

            % Set up.
            value = string.empty();
            pattern = "This is a \w+\.";

            % Exercise and verify.
            mag.validator.mustMatchRegex(value, pattern);
        end

        % Test that error is thrown when value does not match regex.
        function mustMatchRegex_fail(testCase)

            % Set up.
            value = "This is not a value.";
            pattern = "This is a \w+\.";

            % Exercise and verify.
            testCase.verifyError(@() mag.validator.mustMatchRegex(value, pattern), ?MException, ...
                "Error should be thrown when value does not match regex.");
        end
    end
end
