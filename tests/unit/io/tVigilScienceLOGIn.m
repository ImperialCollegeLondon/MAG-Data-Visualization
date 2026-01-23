classdef tVigilScienceLOGIn < MAGIOTestCase
% TVIGILSCIENCELOGIN Unit tests for "mag.vigil.in.ScienceLOG" class.

    properties (TestParameter)
        Sensor = {mag.meta.Sensor.FOB, mag.meta.Sensor.FIB}
    end

    methods (Test)

        % Test that loading LOG file provides correct raw data.
        function load(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "fob_sci_20250919_095246.log.txt");

            % Exercise.
            logFormat = mag.vigil.in.ScienceLOG();
            [rawData, loadedFileName] = logFormat.load(fileName);

            % Verify.
            testCase.assertClass(rawData, "table", "Raw data extracted from LOG should be a table.");
            testCase.assertClass(loadedFileName, "string", "File name should be a string.");

            testCase.verifySize(rawData, [5, 5], "Raw data should have 5 rows and 5 columns (Time, Bx, By, Bz, Range).");
            testCase.verifyEqual(rawData.Properties.VariableNames, cellstr(["Time", "Bx", "By", "Bz", "Range"]), "Column names should match.");
        end

        % Test that loading empty LOG file returns empty table.
        function load_empty(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "fob_sci_20250919_100000.log.txt");

            % Exercise.
            logFormat = mag.vigil.in.ScienceLOG();
            rawData = logFormat.load(fileName);

            % Verify.
            testCase.verifyEmpty(rawData, "Empty file should result in empty table.");
        end

        % Test that processing valid LOG file provides correct science data.
        function process_valid(testCase, Sensor)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "fob_sci_20250919_095246.log.txt");

            % Exercise.
            logFormat = mag.vigil.in.ScienceLOG(Sensor = Sensor);

            [rawData, fileName] = logFormat.load(fileName);
            data = logFormat.process(rawData, fileName);

            % Verify.
            testCase.assertClass(data, "mag.Science", "Data extracted from LOG should be ""mag.Science"".");
            testCase.assertNumElements(data, 1, "One science data should be extracted.");

            testCase.verifyEqual(data.Metadata.Sensor, Sensor, "Sensor should match input.");
            testCase.verifyEqual(data.Metadata.Mode, mag.meta.Mode.Normal, "Mode should be Normal.");
            testCase.verifyEqual(data.Metadata.DataFrequency, 1, "Data frequency should be 1 Hz.");

            testCase.verifySize(data.Data, [5, 4], "Science data should have 5 rows and 4 columns.");
            testCase.verifyTrue(all(ismember(["x", "y", "z", "range"], data.Data.Properties.VariableNames)), "Expected variables should be present.");
        end

        % Test that processing empty LOG file returns empty science data.
        function process_empty(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "fob_sci_20250919_100000.log.txt");

            % Exercise.
            logFormat = mag.vigil.in.ScienceLOG();

            [rawData, fileName] = logFormat.load(fileName);
            data = logFormat.process(rawData, fileName);

            % Verify.
            testCase.assertClass(data, "mag.Science", "Data extracted from empty LOG should be ""mag.Science"".");
            testCase.verifyFalse(data.HasData, "Empty file should result in science with no data.");
        end

        % Test that timestamp is correctly extracted from filename.
        function process_timestamp(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "fob_sci_20250919_095246.log.txt");

            % Exercise.
            logFormat = mag.vigil.in.ScienceLOG();

            [rawData, fileName] = logFormat.load(fileName);
            data = logFormat.process(rawData, fileName);

            % Verify.
            expectedDate = datetime(2025, 09, 19, 09, 52, 46, TimeZone = "UTC");
            testCase.verifyEqual(dateshift(data.Metadata.Timestamp, "start", "second"), expectedDate, "Timestamp should be extracted from filename.");
        end

        % Test that magnetic field values are correctly parsed.
        function process_fieldValues(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "fob_sci_20250919_095246.log.txt");

            % Exercise.
            logFormat = mag.vigil.in.ScienceLOG();

            [rawData, fileName] = logFormat.load(fileName);
            data = logFormat.process(rawData, fileName);

            % Verify.
            testCase.verifyEqual(data.X(1), 100, "First X value should be 100.");
            testCase.verifyEqual(data.Y(1), 200, "First Y value should be 200.");
            testCase.verifyEqual(data.Z(1), 300, "First Z value should be 300.");
        end
    end
end
