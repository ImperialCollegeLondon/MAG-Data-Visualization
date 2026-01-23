classdef tVigilInstrument < matlab.unittest.TestCase
% TVIGILINSTRUMENT Unit tests for "mag.vigil.Instrument" class.

    properties (TestParameter)
        HasProperty = {"HasData", "HasMetadata", "HasScience", "HasHK"}
    end

    methods (Test)

        % Test that "Has*" properties return "false" when object has no
        % data.
        function hasProperties_noData(testCase, HasProperty)

            % Set up.
            instrument = mag.vigil.Instrument();

            % Exercise and verify.
            testCase.verifyFalse(instrument.(HasProperty), """" + HasProperty + """ should return ""false"" when object has no data.");
        end

        % Test that "TimeRange" is missing when object has no data.
        function timeRange_noData(testCase)

            % Set up.
            instrument = mag.vigil.Instrument();

            % Exercise and verify.
            testCase.verifyTrue(all(ismissing(instrument.TimeRange)), """TimeRange"" should return ""missing"" when object has no data.");
        end

        % Test that "Outboard" returns empty when no outboard data.
        function outboard_noData(testCase)

            % Set up.
            instrument = mag.vigil.Instrument();

            % Exercise and verify.
            testCase.verifyEmpty(instrument.Outboard, "Outboard should be empty when no data.");
        end

        % Test that "Inboard" returns empty when no inboard data.
        function inboard_noData(testCase)

            % Set up.
            instrument = mag.vigil.Instrument();

            % Exercise and verify.
            testCase.verifyEmpty(instrument.Inboard, "Inboard should be empty when no data.");
        end

        % Test that "Outboard" returns correct science data.
        function outboard_withData(testCase)

            % Set up.
            instrument = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyEqual(instrument.Outboard.Metadata.Sensor, mag.meta.Sensor.FOB, "Outboard should return FOB sensor data.");
        end

        % Test that "Inboard" returns correct science data.
        function inboard_withData(testCase)

            % Set up.
            instrument = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyEqual(instrument.Inboard.Metadata.Sensor, mag.meta.Sensor.FIB, "Inboard should return FIB sensor data.");
        end

        % Test that "TimeRange" is based on both Outboard and Inboard data.
        function timeRange_withData(testCase)

            % Set up.
            instrument = testCase.createTestData();

            minTime = datetime("yesterday", TimeZone = "UTC");
            maxTime = datetime("tomorrow", TimeZone = "UTC");

            instrument.Outboard.Data.t(1) = minTime;
            instrument.Inboard.Data.t(end) = maxTime;

            expectedTimeRange = [minTime, maxTime];

            % Exercise and verify.
            testCase.verifyEqual(instrument.TimeRange, expectedTimeRange, """TimeRange"" should return minimum and maximum time based on both sensors.");
        end
    end

    methods (Access = private)

        function instrument = createTestData(~)

            % Create FOB science data.
            fobTime = datetime("now", TimeZone = "UTC") + seconds(0:4)';
            fobData = timetable(fobTime, rand(5, 1), rand(5, 1), rand(5, 1), rand(5, 1), VariableNames = ["x", "y", "z", "range"], DimensionNames = ["t", "Data"]);

            fobMetadata = mag.meta.Science(Sensor = mag.meta.Sensor.FOB, Mode = mag.meta.Mode.Normal, DataFrequency = 1);
            fobScience = mag.Science(fobData, fobMetadata);

            % Create FIB science data.
            fibTime = datetime("now", TimeZone = "UTC") + seconds(0:4)';
            fibData = timetable(fibTime, rand(5, 1), rand(5, 1), rand(5, 1), rand(5, 1), VariableNames = ["x", "y", "z", "range"], DimensionNames = ["t", "Data"]);

            fibMetadata = mag.meta.Science(Sensor = mag.meta.Sensor.FIB, Mode = mag.meta.Mode.Normal, DataFrequency = 1);
            fibScience = mag.Science(fibData, fibMetadata);

            % Create instrument.
            instrument = mag.vigil.Instrument();
            instrument.Science = [fobScience, fibScience];
        end
    end
end
