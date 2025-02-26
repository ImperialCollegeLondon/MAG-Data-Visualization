classdef tData < matlab.unittest.TestCase
% TDATA Unit tests for "mag.Data" class.

    methods (Test)

        % Test that metadata "sort" method returns the metadata in the
        % expected order.
        function metadata_sort(testCase)

            % Set up.
            metadata(1) = mag.meta.Science(Timestamp = datetime("today"));
            metadata(2) = mag.meta.Science(Timestamp = datetime("tomorrow"));
            metadata(3) = mag.meta.Science(Timestamp = datetime("yesterday"));

            expectedMetadata = metadata([2, 1, 3]);

            % Exercise.
            sortedMetadata = sort(metadata, "descend");

            % Verify.
            testCase.verifyEqual(sortedMetadata, expectedMetadata, "Sorting should return the expected order.");
        end

        % Test that metadata "struct" method converts to struct.
        function metadata_struct(testCase)

            % Set up.
            setup = mag.meta.Setup(Can = "Can 1", FEE = "FEE3", Harness = "IMAP-IMAP1", Model = "EM2");
            metadata = mag.meta.Science(Setup = setup, Sensor = "FOB", Mode = "Burst", DataFrequency = 4, PacketFrequency = 8, Primary = true);

            expectedStruct = struct(Primary = true, ...
                Setup = struct(Can = "Can 1", FEE = "FEE3", Harness = "IMAP-IMAP1", Model = "EM2"), ...
                Sensor = "FOB", ...
                Mode = "Burst", ...
                DataFrequency = 4, ...
                PacketFrequency = 8, ...
                ReferenceFrame = string.empty(), ...
                Description = string.empty(), ...
                Timestamp = NaT(TimeZone = "UTC"));

            % Exercise.
            structMetadata = struct(metadata);

            % Verify.
            testCase.verifyEqual(structMetadata, expectedStruct, "Converted struct should have the expected values.");
        end

        % Test that metadata "getDisplay" method returns the correct
        % property value for scalar objects.
        function metadata_getDisplay_empty(testCase)

            % Set up.
            metadata = mag.meta.Science();
            metadata.Sensor = mag.meta.Sensor.empty();

            % Exercise.
            value = metadata.getDisplay("Sensor");

            % Verify.
            testCase.verifyEmpty(value, "Display value should be equal to expected value.");
        end

        % Test that metadata "getDisplay" method returns the correct
        % property value for scalar objects.
        function metadata_getDisplay_scalar(testCase)

            % Set up.
            metadata = mag.meta.Science();
            metadata.Sensor = mag.meta.Sensor.FOB;

            expectedValue = mag.meta.Sensor.FOB;

            % Exercise.
            value = metadata.getDisplay("Sensor");

            % Verify.
            testCase.verifyEqual(value, expectedValue, "Display value should be equal to expected value.");
        end

        % Test that metadata "getDisplay" method returns the correct
        % property value for vector objects with the same value.
        function metadata_getDisplay_vectorSameValue(testCase)

            % Set up.
            metadata(1) = mag.meta.Science();
            metadata(2) = mag.meta.Science();
            [metadata.Sensor] = deal(mag.meta.Sensor.FIB);

            expectedValue = mag.meta.Sensor.FIB;

            % Exercise.
            value = metadata.getDisplay("Sensor");

            % Verify.
            testCase.verifyEqual(value, expectedValue, "Display value should be equal to expected value.");
        end

        % Test that metadata "getDisplay" method returns missing value for
        % vector objects with different values.
        function metadata_getDisplay_vectorDifferentValues(testCase)

            % Set up.
            metadata(1) = mag.meta.Science();
            metadata(2) = mag.meta.Science();
            [metadata.Sensor] = deal(mag.meta.Sensor.FIB, mag.meta.Sensor.FOB);

            % Exercise.
            value = metadata.getDisplay("Sensor");

            % Verify.
            testCase.verifyTrue(ismissing(value), "Display value should be equal to expected value.");
        end

        % Test that metadata "getDisplay" method returns the specified
        % alternative value for vector objects with different values.
        function metadata_getDisplay_vectorCustomAlternative(testCase)

            % Set up.
            metadata(1) = mag.meta.Science();
            metadata(2) = mag.meta.Science();
            [metadata.Sensor] = deal(mag.meta.Sensor.FOB, mag.meta.Sensor.FIB);

            expectedValue = "Ciao";

            % Exercise.
            value = metadata.getDisplay("Sensor", expectedValue);

            % Verify.
            testCase.verifyEqual(value, expectedValue, "Display value should be equal to expected value.");
        end

        % Test that "get" method with a single property name returns the
        % selected property.
        function getMethod_singleProperty(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get("Y");

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, "y"}, "Retireved property value should be as expected.");
        end

        % Test that "get" method with multiple scalar property names
        % returns the selected properties.
        function getMethod_multipleProperties_manyScalars(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get("Z", "X");

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, ["z", "x"]}, "Retireved property values should be as expected.");
        end

        % Test that "get" method with a single vector of property names
        % returns the selected properties.
        function getMethod_multipleProperties_singleVector(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get(["Z", "X", "Y"]);

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, ["z", "x", "y"]}, "Retireved property values should be as expected.");
        end

        % Test that "get" method with any other signature calls the
        % built-in method.
        function getMethod_other(testCase)

            % Set up.
            [data, rawData] = testCase.createTestData();

            % Exercise.
            actualData = data.get('Y');

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, "y"}, "Retireved property values should be as expected.");
        end

        % Test that "get" method with an invalid property name throws.
        function getMethod_invalidProperty(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() data.get("A"), "MATLAB:class:setgetPropertyNotFound", "Error should be thrown for invalid property.");
        end

        % Test that "get" method with invalid signature throws.
        function getMethod_invalidSignature(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise and verify.
            testCase.verifyError(@() data.get(1), "MATLAB:class:InvalidArgument", "Error should be thrown for invalid signature.");
            testCase.verifyError(@() data.get(1, 2, 3), "MATLAB:maxrhs", "Error should be thrown for invalid signature.");
            testCase.verifyError(@() data.get("A", 2, "C"), "MATLAB:maxrhs", "Error should be thrown for invalid signature.");
            testCase.verifyError(@() data.get('A', 2), "MATLAB:maxrhs", "Error should be thrown for invalid signature.");
        end

        % Test that "copy" method performs a deep copy of metadata.
        function copyMethod(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            copiedData = data.copy();

            % Verify.
            testCase.verifyNotSameHandle(data, copiedData, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(data.Metadata, copiedData.Metadata, "Copied data should be different instance.");
        end
    end

    methods (Static, Access = private)

        function [data, rawData] = createTestData()

            rawData = timetable(datetime("now") + (1:10)', (1:10)', (11:20)', (21:30)', VariableNames = ["x", "y", "z"]);
            data = mag.Science(rawData, mag.meta.Science());
        end
    end
end
