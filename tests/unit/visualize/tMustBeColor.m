classdef tMustBeColor < matlab.unittest.TestCase
% TMUSTBECOLOR Unit tests for "mag.graphics.chart.Area" class.

    properties (TestParameter)
        SupportedColor = {[], [1, 0, 0], [0, 0.5, 0.25; 0.1, 0.3, 0.2], '', "green", 'red', "none", "#7be7d5"}
        InvalidColor = {1, [1, 0], [1, 0, 0, 1]}
    end

    methods (Test)

        % Test that supported values can be set as colors.
        function supportedValues(~, SupportedColor)
            mag.graphics.mixin.mustBeColor(SupportedColor);
        end

        % Test that invalid values throw an error.
        function invalidValues(testCase, InvalidColor)

            testCase.verifyError(@() mag.graphics.mixin.mustBeColor(InvalidColor), "mag:graphics:InvalidColor", ...
                "Error should be thrown when unsupported value is used.");
        end

        % Test that empty string throws an error.
        function invalidValues_emptyString(testCase)

            testCase.verifyError(@() mag.graphics.mixin.mustBeColor(""), "MATLAB:validators:mustBeNonzeroLengthText", ...
                "Error should be thrown when unsupported value is used.");
        end
    end
end
