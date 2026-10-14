classdef tNoiseThreshold < matlab.unittest.TestCase
% TNOISETHRESHOLD Unit tests for "mag.graphics.psd.NoiseThreshold".

    methods (Test)

        function helioSwarmChart_callableSupportsArrayInputs(testCase)

            chart = mag.graphics.psd.NoiseThreshold.HelioSwarm.getChart();

            x = [1e-4, 1e-3, 1e-2; 1, 1.5, 3];
            y = chart.Callable(x);

            k1 = (log10(15e-3) - log10(1500e-3))/(log10(1) - log10(0.001));
            k2 = (log10(7.5e-3) - log10(15e-3))/(log10(2) - log10(1));

            expected = [1500e-3, 1500e-3, 1500e-3 * (1e-2 / 0.001) ^ k1; ...
                15e-3, 15e-3 * 1.5 ^ k2, 7.5e-3];

            testCase.verifySize(y, size(x), "HelioSwarm threshold should preserve array shape for fplot.");
            testCase.verifyEqual(y, expected, "RelTol", 1e-12, "HelioSwarm threshold values should match the piecewise definition.");
        end
    end
end