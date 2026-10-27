classdef (TestTags = "Performance") tSciencePerformance < MAGPerformanceTestCase
% TSCIENCEPERFORMANCE Performance tests for "mag.Science" class.

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

        % Measure computation of magnetic field magnitude.
        function magnitude(testCase)

            science = testCase.Science;

            while testCase.keepMeasuring()
                b = science.B;
            end

            testCase.verifySize(b, [height(science.Data), 1]);
        end

        % Measure computation of magnetic field derivative.
        function derivative(testCase)

            science = testCase.Science;

            while testCase.keepMeasuring()
                dx = science.dX;
            end

            testCase.verifySize(dx, [height(science.Data), 1]);
        end

        % Measure cropping of data.
        function crop(testCase)

            science = testCase.Science.copy();
            timeFilter = timerange(science.Time(1) + 0.25 * (science.Time(end) - science.Time(1)), science.Time(end));

            testCase.startMeasuring();
            science.crop(timeFilter);
            testCase.stopMeasuring();

            testCase.verifyLessThan(height(science.Data), height(testCase.Science.Data));
        end

        % Measure resampling of data to lower frequency.
        function resample(testCase)

            science = testCase.Science.copy();

            testCase.startMeasuring();
            science.resample(testCase.Frequency / 4);
            testCase.stopMeasuring();

            testCase.verifyEqual(science.Metadata.DataFrequency, testCase.Frequency / 4);
        end

        % Measure downsampling of data to lower frequency.
        function downsample(testCase)

            science = testCase.Science.copy();

            testCase.startMeasuring();
            science.downsample(testCase.Frequency / 4);
            testCase.stopMeasuring();

            testCase.verifyEqual(science.Metadata.DataFrequency, testCase.Frequency / 4);
        end

        % Measure filtering of data.
        function filter(testCase)

            science = testCase.Science.copy();
            numerator = ones(1, 8) / 8;

            % Filtering preserves size of data, so it can be repeated.
            while testCase.keepMeasuring()
                science.filter(numerator);
            end

            testCase.verifySize(science.XYZ, size(testCase.Science.XYZ));
        end
    end
end
