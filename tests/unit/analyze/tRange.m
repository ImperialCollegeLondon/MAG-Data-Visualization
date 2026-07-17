classdef tRange < MAGAnalysisTestCase
% TRANGE Unit tests for "mag.process.Range" class.

    properties (TestParameter)
        % Test with uniform scale factors (backward compatibility)
        UniformUnscaledValue = {ones(4, 3), ones(4, 3), ones(4, 3), ones(4, 3), ones(4, 3)}
        UniformScaleFactor = {zeros(4, 1), ones(4, 1), 2 * ones(4, 1), 3 * ones(4, 1), [0; 1; 2; 3]}
        UniformScaledValue = {2.13618 * ones(4, 3), ...
            0.072 * ones(4, 3), ...
            0.01854 * ones(4, 3), ...
            0.00453 * ones(4, 3), ...
            [2.13618; 0.072; 0.01854; 0.00453] * ones(1, 3)}
    end

    methods (Test, ParameterCombination = "sequential")

        function applyRangeUniform(testCase, UniformUnscaledValue, UniformScaleFactor, UniformScaledValue)

            % Set up.
            rangeStep = mag.process.Range();

            % Exercise.
            scaledValue = rangeStep.applyRange(UniformUnscaledValue, UniformScaleFactor);

            % Verify.
            testCase.verifyEqual(scaledValue, UniformScaledValue, "Scaled value with uniform scale factors should match expectation.", RelTol = 1e-6);
        end

        function applyRangeAxisSpecific(testCase)

            % Set up - create range step with axis-specific scale factors.
            scaleFactors = [1, 2, 3, 4; ...      % Axis 1 scale factors
                            2, 4, 6, 8; ...      % Axis 2 scale factors
                            3, 6, 9, 12];        % Axis 3 scale factors
            rangeStep = mag.process.Range(ScaleFactors = scaleFactors);

            % Test data: 4 observations, 3 axes
            % Each row has a different range value (0, 1, 2, 3)
            unscaledValue = ones(4, 3);
            rangeValues = [0; 1; 2; 3];

            % Expected: each axis scaled by its own factors
            expectedValue = [1, 2, 3; ...     % Range 0: scaled by [1, 2, 3]
                             2, 4, 6; ...     % Range 1: scaled by [2, 4, 6]
                             3, 6, 9; ...     % Range 2: scaled by [3, 6, 9]
                             4, 8, 12];       % Range 3: scaled by [4, 8, 12]

            % Exercise.
            scaledValue = rangeStep.applyRange(unscaledValue, rangeValues);

            % Verify.
            testCase.verifyEqual(scaledValue, expectedValue, "Scaled value with axis-specific scale factors should match expectation.", RelTol = 1e-6);
        end
    end
end
