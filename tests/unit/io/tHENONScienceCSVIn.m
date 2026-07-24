classdef tHENONScienceCSVIn < MAGIOTestCase
% THENONSCIENCECSVIN Unit tests for "mag.henon.in.ScienceCSV" class.

    properties (Constant, Access = private)
        ScaleFactor (1, 1) double = (60000 * 2) / (2^24)
    end

    properties (TestParameter)
        FileDetails = {struct(Extension = "ob", Sensor = mag.meta.Sensor.OBS), ...
            struct(Extension = "ib", Sensor = mag.meta.Sensor.IBS)}
    end

    methods (Test)

        % Test that loading CSV file provides correct raw data.
        function load(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "henon_science.ob");

            % Exercise.
            csvFormat = mag.henon.in.ScienceCSV();
            [rawData, loadedFileName] = csvFormat.load(fileName);

            % Verify.
            testCase.assertClass(rawData, "table", "Raw data extracted from CSV should be a table.");
            testCase.assertClass(loadedFileName, "string", "File name should be a string.");

            testCase.verifySize(rawData, [5, 4], "Raw data should have 5 rows and 4 columns (time,x,y,z).");
            testCase.verifyEqual(rawData.Properties.VariableNames, cellstr(["time", "x", "y", "z"]), "Column names should match.");
        end

        % Test that loading empty CSV file returns empty table.
        function load_empty(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "henon_empty.ob");

            % Exercise.
            csvFormat = mag.henon.in.ScienceCSV();
            rawData = csvFormat.load(fileName);

            % Verify.
            testCase.verifyEmpty(rawData, "Empty file should result in empty table.");
        end

        % Test that processing valid CSV file provides scaled science data.
        function process_valid(testCase, FileDetails)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "henon_science." + FileDetails.Extension);

            % Exercise.
            csvFormat = mag.henon.in.ScienceCSV(Sensor = FileDetails.Sensor);

            [rawData, fileName] = csvFormat.load(fileName);
            data = csvFormat.process(rawData, fileName);

            % Verify.
            testCase.assertClass(data, "mag.Science", "Data extracted from CSV should be ""mag.Science"".");
            testCase.assertNumElements(data, 1, "One science data should be extracted.");

            testCase.verifyEqual(data.Metadata.Sensor, FileDetails.Sensor, "Sensor should match input.");
            testCase.verifyEqual(data.Metadata.Mode, mag.meta.Mode.Normal, "Mode should be Normal.");
            testCase.verifyEqual(data.Metadata.DataFrequency, 1, "Data frequency should be 1 Hz.");

            testCase.verifySize(data.Data, [5, 6], "Science data should have 5 rows and expected variables.");
            testCase.verifyTrue(all(ismember(["x", "y", "z", "range", "compression", "quality"], data.Data.Properties.VariableNames)), "Expected variables should be present.");

            testCase.verifyEqual(data.X(1), 100 * testCase.ScaleFactor, "X should be scaled.", AbsTol = eps(100 * testCase.ScaleFactor));
            testCase.verifyEqual(data.Y(1), 200 * testCase.ScaleFactor, "Y should be scaled.", AbsTol = eps(200 * testCase.ScaleFactor));
            testCase.verifyEqual(data.Z(1), 300 * testCase.ScaleFactor, "Z should be scaled.", AbsTol = eps(300 * testCase.ScaleFactor));
            testCase.verifyEqual(data.Range(1), mag.meta.Range.NaN, "Range should be NaN for HENON.");
        end
    end
end
