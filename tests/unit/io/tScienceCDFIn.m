classdef tScienceCDFIn < MAGIOTestCase
% TSCIENCECDFIN Unit tests for "mag.imap.in.ScienceCDF" class.

    properties (TestParameter)
        ValidFileDetails
        InvalidFileName = {"imap_mag_l1a_burst-maga_20240314_v001.cdf", "imap_mag_l1a_super-mago_20240314_v001.cdf"}
    end

    methods (TestClassSetup)

        % Check that SPDF CDF Toolbox is installed.
        function checkSPDFCDFToolbox(testCase)
            testCase.assumeTrue(exist("spdfcdfinfo", "file") == 2, "SPDF CDF Toolbox not installed. Test skipped.");
        end
    end

    methods (Static, TestParameterDefinition)

        function ValidFileDetails = initializeValidFileDetails()

            fileDetails1 = struct(FileName = "imap_mag_l1a_burst-mago_20240314_v001.cdf", ...
                Sensor = mag.meta.Sensor.FOB, ...
                Mode = mag.meta.Mode.Burst, ...
                Timestamp = datetime(2024, 03, 14, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format));

            fileDetails2 = struct(FileName = "imap_mag_l1a_burst-magi_20240314_v001.cdf", ...
                Sensor = mag.meta.Sensor.FIB, ...
                Mode = mag.meta.Mode.Burst, ...
                Timestamp = datetime(2024, 03, 14, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format));

            ValidFileDetails = {fileDetails1, fileDetails2};
        end
    end

    methods (Test)

        % Test that loading CDF file provides correct information.
        function load(testCase)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, "imap_mag_l1a_burst-mago_20240314_v001.cdf");

            % Exercise.
            cdfFormat = mag.imap.in.ScienceCDF();
            [rawData, cdfInfo] = cdfFormat.load(fileName);

            % Verify.
            testCase.assertClass(rawData, "cell", "Raw data extracted from CDF should be a cell array.");
            testCase.assertClass(cdfInfo, "struct", "CDF info should be a struct.");
        end

        % Test that processing valid CDF files provides correct
        % information.
        function process_valid(testCase, ValidFileDetails)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, ValidFileDetails.FileName);
            cdfSettings = mag.io.CDFSettings(Timestamp = "epoch", Field = "vectors", Range = "vectors");

            % Exercise.
            cdfFormat = mag.imap.in.ScienceCDF(CDFSettings = cdfSettings);

            [rawData, cdfInfo] = cdfFormat.load(fileName);
            data = cdfFormat.process(rawData, cdfInfo);

            % Verify.
            testCase.assertClass(data, "mag.Science", "Data extracted from CDF should be ""mag.Science"".");
            testCase.assertNumElements(data, 1, "One and only one science data should be extracted.");

            testCase.verifyEqual(data.MetaData.Sensor, ValidFileDetails.Sensor, "Sensor should be as expected.");
            testCase.verifyEqual(data.MetaData.Mode, ValidFileDetails.Mode, "Mode should be as expected.");
            testCase.verifyEqual(data.MetaData.Timestamp, ValidFileDetails.Timestamp, "Timestamp should be as expected.");

            testCase.verifySize(data.Data, [99, 8], "Science data should be of expected size.");
        end

        % Test that processing invalid CDF files thorws an error.
        function process_invalid(testCase, InvalidFileName)

            % Set up.
            fileName = fullfile(testCase.TestDataLocation, InvalidFileName);

            % Exercise and verify.
            cdfFormat = mag.imap.in.ScienceCDF();

            [rawData, cdfInfo] = cdfFormat.load(fileName);
            testCase.verifyError(@() cdfFormat.process(rawData, cdfInfo), ?MException, "Error should be thrown when file is invalid.");
        end
    end
end
