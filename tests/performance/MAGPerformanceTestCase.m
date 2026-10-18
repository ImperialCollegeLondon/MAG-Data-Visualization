classdef (Abstract) MAGPerformanceTestCase < matlab.perftest.TestCase
% MAGPERFORMANCETESTCASE Base class for all MAG performance tests.

    properties (Constant, Access = protected)
        % FREQUENCY Data frequency (in Hz) of synthetic science data.
        Frequency (1, 1) double = 64
    end

    methods (Static, Access = protected)

        function scienceTT = createScienceTimetable(numSamples, frequency)
        % CREATESCIENCETIMETABLE Create timetable of synthetic science data
        % with deterministic noise.

            arguments
                numSamples (1, 1) double {mustBeInteger, mustBePositive}
                frequency (1, 1) double {mustBePositive} = MAGPerformanceTestCase.Frequency
            end

            rng(42, "twister");

            t = (0:(numSamples - 1))' / frequency;
            time = datetime(2025, 1, 1, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format) + seconds(t);

            xyz = 100 * sin(2 * pi * t * [0.1, 0.3, 0.7]) + randn(numSamples, 3);

            scienceTT = timetable(time, xyz(:, 1), xyz(:, 2), xyz(:, 3), 3 * ones(numSamples, 1), mod(t * frequency, 2^16), ...
                false(numSamples, 1), 16 * ones(numSamples, 1), repmat(mag.meta.Quality.Regular, numSamples, 1), ...
                VariableNames = ["x", "y", "z", "range", "sequence", "compression", "compression_width", "quality"]);
            scienceTT.Properties.VariableContinuity = ["continuous", "continuous", "continuous", "step", "step", "step", "step", "event"];
        end

        function science = createScience(numSamples, frequency)
        % CREATESCIENCE Create science object with synthetic data.

            arguments
                numSamples (1, 1) double {mustBeInteger, mustBePositive}
                frequency (1, 1) double {mustBePositive} = MAGPerformanceTestCase.Frequency
            end

            scienceTT = MAGPerformanceTestCase.createScienceTimetable(numSamples, frequency);
            science = mag.Science(scienceTT, mag.meta.Science(Timestamp = scienceTT.time(1), DataFrequency = frequency));
        end
    end
end
