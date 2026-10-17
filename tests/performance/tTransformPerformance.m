classdef (TestTags = "Performance") tTransformPerformance < MAGPerformanceTestCase
% TTRANSFORMPERFORMANCE Performance tests for "mag.transform" package.

    properties (MethodSetupParameter)
        NumSamples = struct(Small = 1e4, Medium = 1e5, Large = 1e6)
    end

    properties (Access = private)
        Science mag.Science {mustBeScalarOrEmpty}
    end

    methods (TestMethodSetup)

        function createTestData(testCase, NumSamples)
            testCase.Science = testCase.createScience(NumSamples);
        end
    end

    methods (Test)

        % Measure computation of power spectral density.
        function psd(testCase)

            science = testCase.Science;
            transformation = mag.transform.PSD();

            testCase.startMeasuring();
            psd = transformation.apply(science);
            testCase.stopMeasuring();

            testCase.verifyNotEmpty(psd.Data);
        end

        % Measure computation of spectrogram.
        function spectrogram(testCase)

            science = testCase.Science;
            transformation = mag.transform.Spectrogram();

            testCase.startMeasuring();
            spectrum = transformation.apply(science);
            testCase.stopMeasuring();

            testCase.verifyNotEmpty(spectrum);
        end
    end
end
