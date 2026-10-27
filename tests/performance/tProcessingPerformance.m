classdef (TestTags = "Performance") tProcessingPerformance < MAGPerformanceTestCase
% TPROCESSINGPERFORMANCE Performance tests for "mag.process" package.

    properties (MethodSetupParameter)
        NumSamples = struct(Small = 1e4, Medium = 1e5, Large = 1e6)
    end

    properties (TestParameter)
        Step = struct( ...
            AllZero = mag.process.AllZero(Variables = ["x", "y", "z"]), ...
            Calibration = mag.process.Calibration(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
            Compression = mag.process.Compression(CompressionVariable = "compression", CompressionWidthVariable = "compression_width", Variables = ["x", "y", "z"]), ...
            Duplicates = mag.process.Duplicates(), ...
            Missing = mag.process.Missing(Variables = ["x", "y", "z"]), ...
            Range = mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
            Separate = mag.process.Separate(DiscriminationVariable = "time", LargeDiscriminateThreshold = minutes(1), QualityVariable = "quality", Variables = ["x", "y", "z"]), ...
            Smooth = mag.process.Smooth(Variables = ["x", "y", "z"], Window = seconds(1)), ...
            Sort = mag.process.Sort(), ...
            Unwrap = mag.process.Unwrap(Variables = ["x", "y", "z"]))
    end

    properties (Access = private)
        Data timetable
        Metadata mag.meta.Science {mustBeScalarOrEmpty}
    end

    methods (TestMethodSetup)

        function createTestData(testCase, NumSamples)

            testCase.Data = testCase.createScienceTimetable(NumSamples);
            testCase.Metadata = mag.meta.Science(Timestamp = testCase.Data.time(1), DataFrequency = testCase.Frequency);
        end
    end

    methods (Test)

        % Measure application of processing step to science data.
        function apply(testCase, Step)

            data = testCase.Data;
            metadata = testCase.Metadata;

            while testCase.keepMeasuring()
                processedData = Step.apply(data, metadata);
            end

            testCase.verifyClass(processedData, "timetable");
        end
    end
end
