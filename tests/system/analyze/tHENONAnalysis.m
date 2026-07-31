classdef tHENONAnalysis < AnalysisTestCase
% THENONANALYSIS Tests for HENON analysis flow.

    methods (TestMethodSetup)

        function copyDataToWorkingDirectory(testCase)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "..", "test_data", "henon"), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end
    end

    methods (Test)

        % Test that full analysis returns expected results and data format.
        function fullAnalysis(testCase)

            % Exercise.
            analysis = mag.henon.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifyTrue(any(endsWith(analysis.ScienceFileNames, "science_packets.ob")), "OBS file name should be found.");
            testCase.verifyTrue(any(endsWith(analysis.ScienceFileNames, "science_packets.ib")), "IBS file name should be found.");
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyTrue(analysis.Results.HasScience, "Science should be available.");

            outboard = analysis.Results.Outboard;
            inboard = analysis.Results.Inboard;

            testCase.verifyEqual(analysis.Results.Metadata.Mission, mag.meta.Mission.HENON, "Mission metadata should be set to HENON.");
            testCase.verifyEqual(outboard.Metadata.Sensor, mag.meta.Sensor.FOB, "Outboard sensor metadata should be FOB.");
            testCase.verifyEqual(inboard.Metadata.Sensor, mag.meta.Sensor.FIB, "Inboard sensor metadata should be FIB.");
            testCase.verifyEqual(outboard.Metadata.Mode, mag.meta.Mode.Normal, "Outboard mode should be Normal.");
            testCase.verifyEqual(inboard.Metadata.Mode, mag.meta.Mode.Normal, "Inboard mode should be Normal.");
            testCase.verifyEqual(outboard.Metadata.DataFrequency, 1, "Outboard data frequency should be 1 Hz.");
            testCase.verifyEqual(inboard.Metadata.DataFrequency, 1, "Inboard data frequency should be 1 Hz.");
            testCase.verifyEqual(outboard.Range(1), mag.meta.Range.NaN, "Outboard range should be NaN for HENON.");
            testCase.verifyEqual(inboard.Range(1), mag.meta.Range.NaN, "Inboard range should be NaN for HENON.");
        end

        % Test that analysis with no data works.
        function emptyAnalysis(testCase)

            % Set up.
            delete(fullfile(pwd(), "*.ob"));
            delete(fullfile(pwd(), "*.ib"));

            % Exercise.
            analysis = mag.henon.Analysis.start(Location = pwd());

            % Verify.
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyFalse(analysis.Results.HasScience, "Science should be empty.");
        end
    end
end
