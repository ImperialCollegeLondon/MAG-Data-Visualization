classdef tVigilScienceMATOut < MAGIOTestCase
% TVIGILSCIENCEMATOUT Unit tests for "mag.vigil.out.ScienceMAT" class.

%#ok<*DATST>

    methods (Test)

        % Test that export file name is generated correctly with both
        % sensors.
        function getExportFileName_bothSensors(testCase)

            % Set up.
            outboardMetadata = mag.meta.Science(Sensor = "FOB", ...
                Mode = "Normal", ...
                DataFrequency = 1, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            inboardMetadata = mag.meta.Science(Sensor = "FIB", ...
                Mode = "Normal", ...
                DataFrequency = 1, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            data = mag.vigil.Instrument();
            data.Science = [mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1, 2, 3, 0, VariableNames = ["x", "y", "z", "range"]), outboardMetadata), ...
                mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1, 2, 3, 0, VariableNames = ["x", "y", "z", "range"]), inboardMetadata)];

            expectedFileName = compose("%s Normal (1, 1).mat", datetime("now", TimeZone = "UTC", Format = "ddMMyy-HHmm"));

            % Exercise.
            format = mag.vigil.out.ScienceMAT();
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that export file name is generated correctly with outboard
        % only.
        function getExportFileName_outboardOnly(testCase)

            % Set up.
            outboardMetadata = mag.meta.Science(Sensor = "FOB", ...
                Mode = "Normal", ...
                DataFrequency = 2, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            data = mag.vigil.Instrument();
            data.Science = mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1, 2, 3, 0, VariableNames = ["x", "y", "z", "range"]), outboardMetadata);

            expectedFileName = compose("%s Normal (2, 0).mat", datestr(outboardMetadata.Timestamp, "ddmmyy-HHMM"));

            % Exercise.
            format = mag.vigil.out.ScienceMAT();
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that export file name is generated correctly with inboard
        % only.
        function getExportFileName_inboardOnly(testCase)

            % Set up.
            inboardMetadata = mag.meta.Science(Sensor = "FIB", ...
                Mode = "Normal", ...
                DataFrequency = 4, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            data = mag.vigil.Instrument();
            data.Science = mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1, 2, 3, 0, VariableNames = ["x", "y", "z", "range"]), inboardMetadata);

            expectedFileName = compose("%s Normal (0, 4).mat", datestr(inboardMetadata.Timestamp, "ddmmyy-HHMM"));

            % Exercise.
            format = mag.vigil.out.ScienceMAT();
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that conversion to export format returns expected data with
        % both sensors.
        function convertToExportFormat_bothSensors(testCase)

            % Set up.
            data = testCase.createTestData();

            dataProperties = ["Time", "Range"];
            metadataProperties = ["DataFrequency", "Timestamp"];

            % Exercise.
            format = mag.vigil.out.ScienceMAT();
            exportData = format.convertToExportFormat(data);

            % Verify.
            testCase.assertThat(exportData, mag.test.constraint.IsField("B"), """B"" field should exist.");

            B = exportData.B;
            testCase.assertThat(B, mag.test.constraint.IsField("FOB"), """FOB"" field should exist.");
            testCase.assertThat(B, mag.test.constraint.IsField("FIB"), """FIB"" field should exist.");

            for v = ["Outboard", "Inboard"]

                if v == "Outboard"
                    V = B.FOB;
                else
                    V = B.FIB;
                end

                testCase.verifyEqual(V.Data, data.(v).XYZ, "Field should match expectation.");

                for p = dataProperties
                    testCase.verifyEqual(V.(p), data.(v).(p), compose("""%s"" should match expectation.", p));
                end

                testCase.verifyEqual(V.Metadata.Sensor, string(data.(v).Metadata.Sensor), """Sensor"" should match expectation.");
                testCase.verifyEqual(V.Metadata.Mode, string(data.(v).Metadata.Mode), """Mode"" should match expectation.");

                for p = metadataProperties
                    testCase.verifyEqual(V.Metadata.(p), data.(v).Metadata.(p), compose("""%s"" should match expectation.", p));
                end
            end
        end

        % Test that conversion to export format returns expected data with
        % outboard only.
        function convertToExportFormat_outboardOnly(testCase)

            % Set up.
            outboardData = timetable([datetime("yesterday", TimeZone = "UTC"); datetime("today", TimeZone = "UTC")], ...
                [1; 2], [3; 4], [5; 6], [0; 1], ...
                VariableNames = ["x", "y", "z", "range"]);

            outboardMetadata = mag.meta.Science(Sensor = "FOB", ...
                Mode = "Normal", ...
                DataFrequency = 1, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            data = mag.vigil.Instrument();
            data.Science = mag.Science(outboardData, outboardMetadata);

            % Exercise.
            format = mag.vigil.out.ScienceMAT();
            exportData = format.convertToExportFormat(data);

            % Verify.
            testCase.assertThat(exportData, mag.test.constraint.IsField("B"), """B"" field should exist.");
            testCase.assertThat(exportData.B, mag.test.constraint.IsField("FOB"), """FOB"" field should exist.");

            testCase.verifyThat(exportData.B, ~mag.test.constraint.IsField("FIB"), """FIB"" field should not exist.");
        end

        % Test that conversion to export format returns expected data with
        % inboard only.
        function convertToExportFormat_inboardOnly(testCase)

            % Set up.
            inboardData = timetable([datetime("yesterday", TimeZone = "UTC"); datetime("today", TimeZone = "UTC")], ...
                [1; 2], [3; 4], [5; 6], [0; 1], ...
                VariableNames = ["x", "y", "z", "range"]);

            inboardMetadata = mag.meta.Science(Sensor = "FIB", ...
                Mode = "Normal", ...
                DataFrequency = 1, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            data = mag.vigil.Instrument();
            data.Science = mag.Science(inboardData, inboardMetadata);

            % Exercise.
            format = mag.vigil.out.ScienceMAT();
            exportData = format.convertToExportFormat(data);

            % Verify.
            testCase.assertThat(exportData, mag.test.constraint.IsField("B"), """B"" field should exist.");
            testCase.assertThat(exportData.B, mag.test.constraint.IsField("FIB"), """FIB"" field should exist.");

            testCase.verifyThat(exportData.B, ~mag.test.constraint.IsField("FOB"), """FOB"" field should not exist.");
        end
    end

    methods (Static, Access = private)

        function data = createTestData()

            % Create outboard data and metadata.
            outboardData = timetable([datetime("yesterday", TimeZone = "UTC"); datetime("today", TimeZone = "UTC"); datetime("tomorrow", TimeZone = "UTC")], ...
                [100; 110; 120], ...
                [200; 210; 220], ...
                [300; 310; 320], ...
                [0; 1; 0], ...
                VariableNames = ["x", "y", "z", "range"]);

            outboardMetadata = mag.meta.Science(Sensor = "FOB", ...
                Mode = "Normal", ...
                DataFrequency = 1, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            % Create inboard data and metadata.
            inboardData = timetable([datetime("yesterday", TimeZone = "UTC"); datetime("today", TimeZone = "UTC"); datetime("tomorrow", TimeZone = "UTC")], ...
                [50; 55; 60], ...
                [60; 65; 70], ...
                [70; 75; 80], ...
                [1; 0; 1], ...
                VariableNames = ["x", "y", "z", "range"]);

            inboardMetadata = mag.meta.Science(Sensor = "FIB", ...
                Mode = "Normal", ...
                DataFrequency = 1, ...
                Timestamp = datetime("now", TimeZone = "UTC"));

            % Create instrument data.
            data = mag.vigil.Instrument();
            data.Science = [mag.Science(outboardData, outboardMetadata), ...
                mag.Science(inboardData, inboardMetadata)];
        end
    end
end
