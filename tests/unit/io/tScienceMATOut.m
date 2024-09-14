classdef tScienceMATOut < MAGIOTestCase & matlab.mock.TestCase
% TSCIENCEMATOUT Unit tests for "mag.imap.out.ScienceMAT" class.

    methods (Test)

        % Test that export file name is generated correctly.
        function getExportFileName(testCase)

            % Set up.
            primaryMetaData = mag.meta.Science(Mode = "Burst", ...
                Primary = true, ...
                DataFrequency = 128, ...
                Timestamp = datetime("now"));

            secondaryMetaData = mag.meta.Science(Mode = "Burst", ...
                DataFrequency = 64, ...
                Timestamp = datetime("now"));

            data = mag.Instrument(Science = [mag.Science(timetable.empty(), primaryMetaData), ...
                mag.Science(timetable.empty(), secondaryMetaData)]);

            expectedFileName = compose("%s Burst (128, 64).mat", datetime("now", Format = "ddMMyy-HHmm"));

            % Exercise.
            format = mag.imap.out.ScienceMAT();
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that export file name is generated correctly for I-ALiRT.
        function getExportFileName_IALiRT(testCase)

            % Set up.
            primaryMetaData = mag.meta.Science(Mode = "IALiRT", ...
                Primary = true, ...
                DataFrequency = 0.25, ...
                Timestamp = datetime("now"));

            secondaryMetaData = mag.meta.Science(Mode = "IALiRT", ...
                DataFrequency = 0.25, ...
                Timestamp = datetime("now"));

            data = mag.Instrument(Science = [mag.Science(timetable.empty(), primaryMetaData), ...
                mag.Science(timetable.empty(), secondaryMetaData)]);

            expectedFileName = compose("%s IALiRT (0.25, 0.25).mat", datetime("now", Format = "ddMMyy-HHmm"));

            % Exercise.
            format = mag.imap.out.ScienceMAT();
            actualFileName = format.getExportFileName(data);

            % Verify.
            testCase.verifyEqual(actualFileName, expectedFileName, "Export file name should match expectation.");
        end

        % Test that conversion to export format returns expected data.
        function convertToExportFormat(testCase)

            % Set up.
            data = testCase.createTestData();

            dataProperties = ["Time", "Range", "Sequence", "Compression"];
            metaDataProperties = ["Primary", "DataFrequency", "PacketFrequency", "ReferenceFrame", "Description", "Timestamp"];
            setupProperties = ["Model", "FEE", "Harness", "Can"];

            % Exercise.
            format = mag.imap.out.ScienceMAT();
            exportData = format.convertToExportFormat(data);

            % Verify.
            testCase.assertThat(exportData, mag.test.constraint.IsField("B"), """B"" field should exist.");

            B = exportData.B;
            testCase.assertThat(B, mag.test.constraint.IsField("P"), """P"" field should exist.");
            testCase.assertThat(B, mag.test.constraint.IsField("S"), """S"" field should exist.");

            for v = ["Primary", "Secondary"]

                V = B.(v{1}(1));

                testCase.verifyEqual(V.Data, data.(v).XYZ, "Field should match expectation.");
                testCase.verifyEqual(V.Quality, categorical(string(data.(v).Quality)), "Quality should match expectation.");

                for p = dataProperties
                    testCase.verifyEqual(V.(p), data.(v).(p), compose("""%s"" should match expectation.", p));
                end

                testCase.verifyEqual(V.MetaData.Sensor, string(data.(v).MetaData.Sensor), """Sensor"" should match expectation.");
                testCase.verifyEqual(V.MetaData.Mode, string(data.(v).MetaData.Mode), """Mode"" should match expectation.");

                for p = metaDataProperties
                    testCase.verifyEqual(V.MetaData.(p), data.(v).MetaData.(p), compose("""%s"" should match expectation.", p));
                end

                for p = setupProperties
                    testCase.verifyEqual(V.MetaData.(p), data.(v).MetaData.Setup.(p), compose("""%s"" should match expectation.", p));
                end
            end
        end

        % Test that "write" method saves MAT file.
        function write(testCase)

            % Set up.
            format = testCase.createMock(?mag.io.out.MAT, Strict = true);

            fileName = fullfile(testCase.WorkingDirectory.Folder, "testfile");
            expectedExportData = struct(A = "A", B = 2);

            % Exercise.
            format.write(fileName, expectedExportData);

            % Verify.
            testCase.assertThat(@() isfile(fileName), matlab.unittest.constraints.Eventually(matlab.unittest.constraints.IsTrue()));

            actualExportData = load(fileName, "-mat");

            testCase.assertThat(actualExportData, mag.test.constraint.IsField("A"), """A"" field should exist.");
            testCase.verifyEqual(actualExportData.A, expectedExportData.A, """A"" value should match expectation.");

            testCase.assertThat(actualExportData, mag.test.constraint.IsField("B"), """B"" field should exist.");
            testCase.verifyEqual(actualExportData.B, expectedExportData.B, """B"" value should match expectation.");
        end

        % Test that "write" method appends to existing MAT file, when
        % "Append" property is set to "true".
        function write_append(testCase)

            % Set up.
            format = testCase.createMock(?mag.io.out.MAT, Strict = true);
            format.Append = true;

            fileName = fullfile(testCase.WorkingDirectory.Folder, "testfile");
            expectedExportData1 = struct(A = "A", B = 2);
            expectedExportData2 = struct(C = uint8(3));

            % Exercise.
            format.write(fileName, expectedExportData1);
            format.write(fileName, expectedExportData2);

            % Verify.
            testCase.assertThat(@() isfile(fileName), matlab.unittest.constraints.Eventually(matlab.unittest.constraints.IsTrue()));

            actualExportData = load(fileName, "-mat");

            for f = ["A", "B", "C"]
                testCase.assertThat(actualExportData, mag.test.constraint.IsField(f), compose("""%s"" field should exist.", f));
            end

            testCase.verifyEqual(actualExportData.C, expectedExportData2.C, """C"" value should match expectation.");
        end
    end

    methods (Static, Access = private)

        function data = createTestData()

            % Create primary data and meta data.
            primaryData = timetable([datetime("yesterday"); datetime("today"); datetime("tomorrow")], ...
                1 * ones(3, 1), ...
                2 * ones(3, 1), ...
                3 * ones(3, 1), ...
                [3; 1; 2], ...
                [1; 2; 3], ...
                [false; true; false], ...
                [mag.meta.Quality.Artificial; mag.meta.Quality.Regular; mag.meta.Quality.Bad], ...
                VariableNames = ["x", "y", "z", "range", "sequence", "compression", "quality"]);

            primaryMetaData = mag.meta.Science(Primary = true, ...
                Setup = mag.meta.Setup(Can = "No can", FEE = "FEE3", Harness = "H1", Model = "FM4"), ...
                Sensor = "FIB", ...
                Mode = "Burst", ...
                DataFrequency = 64, ...
                PacketFrequency = 4, ...
                Timestamp = datetime("now"));

            % Create secondary data and meta data.
            secondaryData = timetable([datetime("yesterday"); datetime("today"); datetime("tomorrow")], ...
                3 * ones(3, 1), ...
                1 * ones(3, 1), ...
                2 * ones(3, 1), ...
                [2; 1; 3], ...
                [4; 5; 6], ...
                [true; false; false], ...
                [mag.meta.Quality.Regular; mag.meta.Quality.Bad; mag.meta.Quality.Artificial], ...
                VariableNames = ["x", "y", "z", "range", "sequence", "compression", "quality"]);

            secondaryMetaData = mag.meta.Science(Primary = false, ...
                Setup = mag.meta.Setup(Can = "Yes can", FEE = "FEE2", Harness = "H2", Model = "FM2"), ...
                Sensor = "FOB", ...
                Mode = "Burst", ...
                DataFrequency = 8, ...
                PacketFrequency = 4, ...
                Timestamp = datetime("now"));

            % Create instrument data.
            data = mag.Instrument(Science = [mag.Science(primaryData, primaryMetaData), ...
                mag.Science(secondaryData, secondaryMetaData)]);
        end
    end
end
