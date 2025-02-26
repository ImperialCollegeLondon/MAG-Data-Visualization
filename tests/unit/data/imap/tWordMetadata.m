classdef tWordMetadata < matlab.unittest.TestCase
% TWORDMETADATA Unit tests for "mag.impa.meta.Word" class.

    properties (Access = private)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end

    methods (Test)

        % Test that files that do not exist are not supported.
        function isNotSupported_doesNotExist(testCase)

            wordProvider = mag.imap.meta.Word();

            testCase.verifyFalse(wordProvider.isSupported("file-that_does/not,exist.docx"), ...
                "Nonexistent file should not be supported.");
        end

        % Test that files without metadata tables are not supported.
        function isNotSupported_noMetadataTable(testCase)

            wordProvider = mag.imap.meta.Word();

            testCase.verifyFalse(wordProvider.isSupported(fullfile(testCase.WorkingDirectory.StartingFolder, "test_data", "IMAP-OPS-TE-ICL-001 Metadata Test (No table).docx")), ...
                "Invalid Word file should not be supported.");
        end

        % Test that metadata is loaded correctly from 001 files.
        function load_001Metadata(testCase)

            % Set up.
            wordFile = fullfile(testCase.WorkingDirectory.StartingFolder, "test_data", "IMAP-OPS-TE-ICL-001 Metadata Test.docx");

            instrumentMetadata = mag.meta.Instrument();
            primarySetup = mag.meta.Setup();
            secondarySetup = mag.meta.Setup();

            % Exercise.
            wordProvider = mag.imap.meta.Word();
            testCase.assertTrue(wordProvider.isSupported(wordFile), "Metadata file should be supported.");

            wordProvider.load(wordFile, instrumentMetadata, primarySetup, secondarySetup);

            % Verify instrument.
            testCase.verifyEmpty(instrumentMetadata.Mission, "Mission property should be empty.");
            testCase.verifyEqual(instrumentMetadata.Model, "EM", "Model should match expectation.");
            testCase.verifyEqual(instrumentMetadata.BSW, "4.0", "BSW should match expectation.");
            testCase.verifyEqual(instrumentMetadata.ASW, "2.5.1", "ASW should match expectation.");
            testCase.verifyEqual(instrumentMetadata.GSE, "15.2", "GSE should match expectation.");
            testCase.verifyEqual(instrumentMetadata.Operator, "Michele", "Operator should match expectation.");
            testCase.verifyEqual(instrumentMetadata.Description, "Metadata Test", "Description should match expectation.");
            testCase.verifyEqual(instrumentMetadata.Timestamp, datetime(2025, 2, 26, 12, 36, 0, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                "Timestamp should match expectation.");

            % Verify primary.
            testCase.verifyEqual(primarySetup.Model, "FJ1", "Model should match expectation.");
            testCase.verifyEqual(primarySetup.FEE, "FEE1", "FEE should match expectation.");
            testCase.verifyEqual(primarySetup.Harness, "My super harness", "Harness should match expectation.");
            testCase.verifyEqual(primarySetup.Can, "N/A", "Can should match expectation.");

            % Verify secondary.
            testCase.verifyEqual(secondarySetup.Model, "IMAP-E21", "Model should match expectation.");
            testCase.verifyEqual(secondarySetup.FEE, "FEE2", "FEE should match expectation.");
            testCase.verifyEqual(secondarySetup.Harness, "N/A", "Harness should match expectation.");
            testCase.verifyEqual(secondarySetup.Can, "Mega Can", "Can should match expectation.");
        end

        % Test that metadata is loaded correctly from 002 files.
        function load_002Metadata(testCase)

            % Set up.
            wordFile = fullfile(testCase.WorkingDirectory.StartingFolder, "test_data", "IMAP-OPS-TE-ICL-002 Metadata Test.docx");

            instrumentMetadata = mag.meta.Instrument();
            primarySetup = mag.meta.Setup();
            secondarySetup = mag.meta.Setup();

            % Exercise.
            wordProvider = mag.imap.meta.Word();
            testCase.assertTrue(wordProvider.isSupported(wordFile), "Metadata file should be supported.");

            wordProvider.load(wordFile, instrumentMetadata, primarySetup, secondarySetup);

            % Verify instrument.
            testCase.verifyEmpty(instrumentMetadata.Mission, "Mission property should be empty.");
            testCase.verifyEqual(instrumentMetadata.Model, "FM", "Model should match expectation.");
            testCase.verifyEqual(instrumentMetadata.BSW, "1.2", "BSW should match expectation.");
            testCase.verifyEqual(instrumentMetadata.ASW, "3.4", "ASW should match expectation.");
            testCase.verifyEqual(instrumentMetadata.GSE, "5.6.7", "GSE should match expectation.");
            testCase.verifyEqual(instrumentMetadata.Operator, "Michele", "Operator should match expectation.");
            testCase.verifyEqual(instrumentMetadata.Description, "Other Metadata Test", "Description should match expectation.");
            testCase.verifyEqual(instrumentMetadata.Timestamp, datetime(2025, 1, 12, 18, 43, 05, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format), ...
                "Timestamp should match expectation.");

            % Verify primary.
            testCase.verifyEqual(primarySetup.Model, "SOLO-I-CAN", "Model should match expectation.");
            testCase.verifyEqual(primarySetup.FEE, "FEE3", "FEE should match expectation.");
            testCase.verifyEqual(primarySetup.Harness, "Harness", "Harness should match expectation.");
            testCase.verifyEqual(primarySetup.Can, "Super Can", "Can should match expectation.");

            % Verify secondary.
            testCase.verifyEqual(secondarySetup.Model, "FIB2", "Model should match expectation.");
            testCase.verifyEqual(secondarySetup.FEE, "FEE4", "FEE should match expectation.");
            testCase.verifyEqual(secondarySetup.Harness, "Other harness", "Harness should match expectation.");
            testCase.verifyEqual(secondarySetup.Can, "N/A", "Can should match expectation.");
        end
    end
end
