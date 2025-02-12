classdef tPSD < matlab.unittest.TestCase
% TPSD Unit tests for "mag.psd" function.

    methods (Test)

        % Test that PSD can detect sine wave frequency, with default
        % options.
        function psd_sineWave_default(testCase)

            % Set up.
            science = testCase.createSineWaveTestData();

            % Execute.
            psd = mag.psd(science);

            % Verify.
            [~, idxMax] = max([psd.X, psd.Y, psd.Z]);

            testCase.verifyEqual(psd.Frequency(idxMax), [50; 100; 150], "PSD max frequency should match sine wave frequency.");
        end

        % Test that PSD can detect sine wave frequency, with selected data
        % only.
        function psd_sineWave_startAndDuration(testCase)

            % Set up.
            science = testCase.createSineWaveTestData();

            % Execute.
            psd = mag.psd(science, Start = science.Time(10), Duration = milliseconds(500));

            % Verify.
            [~, idxMax] = max([psd.X, psd.Y, psd.Z]);

            testCase.verifyThat(psd.Frequency(idxMax), matlab.unittest.constraints.IsEqualTo([50; 100; 150], Within = matlab.unittest.constraints.RelativeTolerance(0.1)), ...
                "PSD max frequency should match sine wave frequency.");
        end
    end

    methods (Static, Access = private)

        function [science, rawData] = createSineWaveTestData()

            num = 1000;

            timestamp = datetime("now", TimeZone = "UTC") + milliseconds(1:num)';

            t = seconds(timestamp - timestamp(1));
            x = sin(100 * pi * t);
            y = sin(200 * pi * t);
            z = sin(300 * pi * t);

            rawData = timetable(timestamp, x, y, z, 3 * ones(num, 1), (1:num)', VariableNames = ["x", "y", "z", "range", "sequence"]);
            science = mag.Science(rawData, mag.meta.Science(Timestamp = datetime("now", TimeZone = "UTC")));
        end
    end
end
