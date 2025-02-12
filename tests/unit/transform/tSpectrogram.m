classdef tSpectrogram < matlab.unittest.TestCase
% TSPECTROGRAM Unit tests for "mag.spectrogram" function.

    methods (Test)

        % Test that spectrogram can detect sine wave frequency, with
        % default options.
        function spectrogram_sineWave_default(testCase)

            % Set up.
            science = testCase.createSineWaveTestData();

            % Execute.
            spectrum = mag.spectrogram(science);

            % Verify.
            [~, idxMax] = max(max(spectrum.DependentVariables, [], 2), [], 1);

            testCase.verifyThat(spectrum.Frequency(squeeze(idxMax)), matlab.unittest.constraints.IsEqualTo([50; 100; 150], Within = matlab.unittest.constraints.RelativeTolerance(0.1)), ...
                "Spectrogram max frequency should match sine wave frequency.");
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
