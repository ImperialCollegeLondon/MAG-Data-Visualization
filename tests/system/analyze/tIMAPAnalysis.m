classdef tIMAPAnalysis < matlab.unittest.TestCase
% TIMAPANALYSIS Tests for analysis flow.

    properties (Access = private)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end

    methods (Test)

        % Test that full analysis returns expected results and data format.
        function fullAnalysis(testCase)

            % Set up.
            testCase.copyData();

            timeRanges = [datetime("10-Apr-2024 14:23:14.4858", TimeZone = "UTC"), datetime("10-Apr-2024 14:25:03.4748", TimeZone = "UTC"); ...
                datetime("10-Apr-2024 14:25:03.4826", TimeZone = "UTC"), datetime("10-Apr-2024 14:26:07.9825", TimeZone = "UTC"); ...
                datetime("10-Apr-2024 14:26:07.9903", TimeZone = "UTC"), datetime("10-Apr-2024 14:30:08.4853", TimeZone = "UTC")];

            modes = [mag.meta.Mode.Normal, mag.meta.Mode.Burst, mag.meta.Mode.Normal];
            dataFrequencies = [2, 128, 2];
            packetFrequencies = [8, 2, 8];

            expectedResults = load("results.mat", "results").results;

            % Exercise.
            analysis = mag.IMAPAnalysis.start(Location = pwd());

            % Verify file names.
            testCase.verifySubstring(analysis.EventFileNames, "20240410_152136.html", "Event file names do not match.");
            testCase.verifySubstring(analysis.MetaDataFileNames, "IMAP - MAG.msg", "Meta data file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "MAGScience-burst-(128,128)-2s-20240410-15h25.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "MAGScience-normal-(2,2)-8s-20240410-15h23.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(3), "MAGScience-normal-(2,2)-8s-20240410-15h26.csv", "Science file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_pwr.MAG_HSK_PW_20240410_152125.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_stat.MAG_HSK_STATUS_20240410_152125.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{3}, "idle_export_conf.MAG_HSK_SID15_20240410_152125.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{4}, "idle_export_proc.MAG_HSK_PROCSTAT_20240410_152125.csv", "HK file names do not match.");

            % Verify modes.
            results = analysis.getAllModes();
            testCase.assertNumElements(results, 3, "3 modes should exist.");

            for i = 1:3

                % Verify meta data.
                testCase.verifyEqual(results(i).Primary.MetaData.Mode, modes(i), "Mode does not match expectation.");
                testCase.verifyEqual(results(i).Secondary.MetaData.Mode, modes(i), "Mode does not match expectation.");

                testCase.verifyEqual(results(i).Primary.MetaData.DataFrequency, dataFrequencies(i), "Data frequency does not match expectation.");
                testCase.verifyEqual(results(i).Secondary.MetaData.DataFrequency, dataFrequencies(i), "Data frequency does not match expectation.");

                testCase.verifyEqual(results(i).Primary.MetaData.PacketFrequency, packetFrequencies(i), "Packet frequency does not match expectation.");
                testCase.verifyEqual(results(i).Secondary.MetaData.PacketFrequency, packetFrequencies(i), "Packet frequency does not match expectation.");

                % Verify time range.
                testCase.assertLessThanOrEqual(results(i).TimeRange - timeRanges(i, :), milliseconds(1), "Time range does not match expectation.");

                % Verify science.
                for j = 1:2
                    testCase.verifyEqual(results(i).Science(j).Data, expectedResults(i).Science(j).Data, "Analysis results should match expectation.");
                end
            end
        end
    end

    methods (Access = private)

        function copyData(testCase)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "data"), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end
    end
end
