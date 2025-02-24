classdef tRange < MAGAnalysisTestCase
% TRANGE Unit tests for "mag.process.Range" class.

    properties (TestParameter)
        UnscaledValue = {ones(4, 4), ones(4, 4), ones(4, 4), ones(4, 4), ones(4, 4)}
        ScaleFactor = {zeros(4, 1), ones(4, 1), 2 * ones(4, 1), 3 * ones(4, 1), [0; 1; 2; 3]}
        ScaledValue = {2.13618 * ones(4, 4), ...
            0.072 * ones(4, 4), ...
            0.01854 * ones(4, 4), ...
            0.00453 * ones(4, 4), ...
            [2.13618; 0.072; 0.01854; 0.00453] * ones(1, 4)}
    end

    methods (Test, ParameterCombination = "sequential")

        function applyRange(testCase, UnscaledValue, ScaleFactor, ScaledValue)

            % Set up.
            rangeStep = mag.process.Range();

            % Exercise.
            scaledValue = rangeStep.applyRange(UnscaledValue, ScaleFactor);

            % Verify.
            testCase.verifyEqual(scaledValue, ScaledValue, "Scaled value should match expectation.");
        end
    end
end
