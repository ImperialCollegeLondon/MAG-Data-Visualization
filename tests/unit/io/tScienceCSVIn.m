classdef tScienceCSVIn < MAGIOTestCase
% TSCIENCECSVIN Unit tests for "mag.imap.in.ScienceCSV" class.

    properties (TestParameter)
        ValidFileDetails
        InvalidFileName = {"super_data20240410-15h26.csv"}
    end

    methods (TestClassSetup)

        % Check that MICE Toolbox is installed.
        function checkSPDFCDFToolbox(testCase)
            testCase.assumeTrue(exist("mice", "file") == 3, "MICE Toolbox not installed. Test skipped.");
        end
    end

    methods (Static, TestParameterDefinition)

        function ValidFileDetails = initializeValidFileDetails()

            fileDetails1 = struct(FileName = "MAGScience-normal-(2,2)-8s-20240410-15h26.csv", ...
                Mode = mag.meta.Mode.Normal, ...
                PacketFrequency = 8, ...
                PrimarySensor = mag.meta.Sensor.FOB, ...
                PrimaryDataFrequency = 2, ...
                SecondarySensor = mag.meta.Sensor.FIB, ...
                SecondaryDataFrequency = 2, ...
                Timestamp = datetime(2024, 04, 10, 15, 26, 00, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                Size = [96, 10]);

            fileDetails2 = struct(FileName = "MAGScience-burst-(128,128)-2s-20240410-15h25.csv", ...
                Mode = mag.meta.Mode.Burst, ...
                PacketFrequency = 2, ...
                PrimarySensor = mag.meta.Sensor.FOB, ...
                PrimaryDataFrequency = 128, ...
                SecondarySensor = mag.meta.Sensor.FIB, ...
                SecondaryDataFrequency = 128, ...
                Timestamp = datetime(2024, 04, 10, 15, 25, 00, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                Size = [2560, 10]);

            fileDetails3 = struct(FileName = "MAGScience-IALiRT-20240410-15h23.csv", ...
                Mode = mag.meta.Mode.IALiRT, ...
                PacketFrequency = 4, ...
                PrimarySensor = mag.meta.Sensor.FOB, ...
                PrimaryDataFrequency = 0.25, ...
                SecondarySensor = mag.meta.Sensor.FIB, ...
                SecondaryDataFrequency = 0.25, ...
                Timestamp = datetime(2024, 04, 10, 15, 23, 00, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                Size = [99, 10]);

            fileDetails4 = struct(FileName = "normal_data20240410-15h26.csv", ...
                Mode = mag.meta.Mode.Normal, ...
                PacketFrequency = 8, ...
                PrimarySensor = mag.meta.Sensor.FOB, ...
                PrimaryDataFrequency = 2, ...
                SecondarySensor = mag.meta.Sensor.FIB, ...
                SecondaryDataFrequency = 2, ...
                Timestamp = datetime(2024, 04, 10, 15, 26, 00, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                Size = [96, 10]);

            fileDetails5 = struct(FileName = "burst_data20240410-15h25.csv", ...
                Mode = mag.meta.Mode.Burst, ...
                PacketFrequency = 2, ...
                PrimarySensor = mag.meta.Sensor.FOB, ...
                PrimaryDataFrequency = 128, ...
                SecondarySensor = mag.meta.Sensor.FIB, ...
                SecondaryDataFrequency = 128, ...
                Timestamp = datetime(2024, 04, 10, 15, 25, 00, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                Size = [2560, 10]);

            ValidFileDetails = {fileDetails1, fileDetails2, fileDetails3, fileDetails4, fileDetails5};
        end
    end

    methods (Test)

        % Test that loading CSV file provides correct information.
        function load(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "MAGScience-normal-(2,2)-8s-20240410-15h26.csv");

            % Exercise.
            csvFormat = mag.imap.in.ScienceCSV();
            [rawData, fileName] = csvFormat.load(fileName);

            % Verify.
            testCase.assertClass(rawData, "table", "Raw data extracted from CSV should be a table.");
            testCase.assertClass(fileName, "string", "File name should be a struct.");
        end

        % Test that loading empty CSV file returns empty table.
        function load_empty(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "empty.csv");

            % Exercise and verify.
            csvFormat = mag.imap.in.ScienceCSV();
            testCase.verifyEmpty(csvFormat.load(fileName), "Empty file should result in empty table.");
        end

        % Test that processing valid CSV files provides correct
        % information.
        function process_valid(testCase, ValidFileDetails)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, ValidFileDetails.FileName);

            % Exercise.
            csvFormat = mag.imap.in.ScienceCSV();

            [rawData, fileName] = csvFormat.load(fileName);
            data = csvFormat.process(rawData, fileName);

            % Verify.
            testCase.assertClass(data, "mag.Science", "Data extracted from CDF should be ""mag.Science"".");
            testCase.assertNumElements(data, 2, "Two and only two science data should be extracted.");

            testCase.verifyEqual(data(1).MetaData.Sensor, ValidFileDetails.PrimarySensor, "Primary sensor should be as expected.");
            testCase.verifyEqual(data(1).MetaData.DataFrequency, ValidFileDetails.PrimaryDataFrequency, "Primary data frequency should be as expected.");
            testCase.verifyEqual(data(2).MetaData.Sensor, ValidFileDetails.SecondarySensor, "Secondary sensor should be as expected.");
            testCase.verifyEqual(data(2).MetaData.DataFrequency, ValidFileDetails.SecondaryDataFrequency, "Secondary data frequency should be as expected.");

            for i = 1:2

                testCase.verifyEqual(data(i).MetaData.Mode, ValidFileDetails.Mode, "Mode should be as expected.");
                testCase.verifyEqual(data(i).MetaData.PacketFrequency, ValidFileDetails.PacketFrequency, "Packet frequency should be as expected.");
                testCase.verifyEqual(data(i).MetaData.Timestamp, ValidFileDetails.Timestamp, "Timestamp should be as expected.");

                testCase.verifySize(data(i).Data, ValidFileDetails.Size, "Science data should be of expected size.");
            end
        end

        % Test that processing invalid CSV files throws an error.
        function process_invalid(testCase, InvalidFileName)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, InvalidFileName);

            % Exercise and verify.
            csvFormat = mag.imap.in.ScienceCSV();

            [rawData, fileName] = csvFormat.load(fileName);
            testCase.verifyError(@() csvFormat.process(rawData, fileName), ?MException, "Error should be thrown when file is invalid.");
        end
    end
end
