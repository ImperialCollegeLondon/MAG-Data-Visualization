classdef tVigilAnalysis < AnalysisTestCase
% TVIGILANALYSIS Tests for Vigil analysis flow.

    methods (TestMethodSetup)

        function copyDataToWorkingDirectory(testCase)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "..", "test_data", "vigil"), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end
    end

    methods (Test)

        % Test that full analysis returns expected results and data format.
        function fullAnalysis(testCase)

            % Exercise.
            analysis = mag.vigil.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifySubstring(analysis.ScienceFileNames(1), "fib_sci_20250919_095246.log.txt", "FIB file name should be found.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "fob_sci_20250919_095246.log.txt", "FOB file name should be found.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyEqual(analysis.Results.Outboard.Metadata.Sensor, mag.meta.Sensor.OBS, "Outboard sensor metadata should be OBS.");
            testCase.verifyEqual(analysis.Results.Inboard.Metadata.Sensor, mag.meta.Sensor.IBS, "Inboard sensor metadata should be IBS.");

            testCase.verifyEqual(analysis.Results.Outboard.Metadata.Mode, mag.meta.Mode.Normal, "Outboard mode should be Normal.");
            testCase.verifyEqual(analysis.Results.Inboard.Metadata.Mode, mag.meta.Mode.Normal, "Inboard mode should be Normal.");
        end

        % Test that analysis with only outboard data works.
        function outboardOnlyAnalysis(testCase)

            % Set up.
            delete(fullfile(pwd(), "fib_sci_*.log.txt"));

            % Exercise.
            analysis = mag.vigil.Analysis.start(Location = pwd());

            % Verify.
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyTrue(analysis.Results.Outboard.HasData, "Outboard should have data.");
            testCase.verifyFalse(analysis.Results.Inboard.HasData, "Inboard should not have data.");
        end

        % Test that analysis with only inboard data works.
        function inboardOnlyAnalysis(testCase)

            % Set up.
            delete(fullfile(pwd(), "fob_sci_*.log.txt"));

            % Exercise.
            analysis = mag.vigil.Analysis.start(Location = pwd());

            % Verify.
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyFalse(analysis.Results.Outboard.HasData, "Outboard should not have data.");
            testCase.verifyTrue(analysis.Results.Inboard.HasData, "Inboard should have data.");
        end

        % Test that analysis with no data works.
        function emptyAnalysis(testCase)

            % Set up.
            delete(fullfile(pwd(), "*_sci_*.log.txt"));

            % Exercise.
            analysis = mag.vigil.Analysis.start(Location = pwd());

            % Verify.
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyEmpty(analysis.Results.Outboard, "Outboard should not have data.");
            testCase.verifyEmpty(analysis.Results.Inboard, "Inboard should not have data.");
        end
    end
end
