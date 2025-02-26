classdef tJSONMetadata < matlab.unittest.TestCase
% TJSONMETADATA Unit tests for "mag.impa.meta.JSON" class.

    properties (Access = private)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    properties (TestParameter)
        SupportedFileName = {"test.json", "imap_setup.json"}
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end

    methods (Test)

        % Test that JSON files that exist are supported.
        function isSupported(testCase, SupportedFileName)

            % Set up.
            writelines("abc", SupportedFileName);

            % Exercise and verify.
            jsonProvider = mag.imap.meta.JSON();

            testCase.verifyTrue(jsonProvider.isSupported(SupportedFileName), ...
                "JSON file should be supported.");
        end

        % Test that files that do not exist are not supported.
        function isNotSupported_doesNotExist(testCase)

            jsonProvider = mag.imap.meta.JSON();

            testCase.verifyFalse(jsonProvider.isSupported("file-that_does/not,exist.json"), ...
                "Nonexistent file should not be supported.");
        end

        % Test that metadata is loaded correctly, even when one field
        % (Primary) is empty.
        function load_incompleteMetadata(testCase)

            % Set up.
            data = struct(Instrument = struct(Mission = "IMAP", ASW = "v1.2.3"), ...
                Secondary = struct(Model = "ABC123", Harness = "MySpecial-Harness"));

            jsonFile = "test-metadata.json";
            writestruct(data, jsonFile);

            instrumentMetadata = mag.meta.Instrument();
            primarySetup = mag.meta.Setup();
            secondarySetup = mag.meta.Setup();

            % Exercise.
            jsonProvider = mag.imap.meta.JSON();
            testCase.assertTrue(jsonProvider.isSupported(jsonFile), "Metadata file should be supported.");

            jsonProvider.load(jsonFile, instrumentMetadata, primarySetup, secondarySetup);

            % Verify instrument.
            testCase.verifyEqual(instrumentMetadata.Mission, mag.meta.Mission.IMAP, "Mission should match expectation.");
            testCase.verifyEqual(instrumentMetadata.ASW, "v1.2.3", "ASW should match expectation.");

            for emptyProperty = ["Model", "BSW", "GSE", "Operator", "Description"]
                testCase.verifyEmpty(instrumentMetadata.(emptyProperty), compose("%s property should be empty.", emptyProperty));
            end

            % Verify primary.
            for emptyProperty = ["Model", "FEE", "Harness", "Can"]
                testCase.verifyEmpty(primarySetup.(emptyProperty), compose("%s property should be empty.", emptyProperty));
            end

            % Verify secondary.
            testCase.verifyEqual(secondarySetup.Model, "ABC123", "Model should match expectation.");
            testCase.verifyEqual(secondarySetup.Harness, "MySpecial-Harness", "Harness should match expectation.");

            for emptyProperty = ["FEE", "Can"]
                testCase.verifyEmpty(secondarySetup.(emptyProperty), compose("%s property should be empty.", emptyProperty));
            end
        end

        % Test that error is thrown when invalid property is set in
        % metadata.
        function load_invalidPropertyName(testCase)

            % Set up.
            data = struct(Instrument = struct(NotAProperty = "NotAValue"));

            jsonFile = "test-metadata.json";
            writestruct(data, jsonFile);

            instrumentMetadata = mag.meta.Instrument();
            primarySetup = mag.meta.Setup();
            secondarySetup = mag.meta.Setup();

            % Exercise and verify.
            jsonProvider = mag.imap.meta.JSON();
            testCase.assertTrue(jsonProvider.isSupported(jsonFile), "Metadata file should be supported.");

            testCase.verifyError(@() jsonProvider.load(jsonFile, instrumentMetadata, primarySetup, secondarySetup), ?MException, ...
                "Error should be thrown when invalid property name is used.");
        end
    end
end
