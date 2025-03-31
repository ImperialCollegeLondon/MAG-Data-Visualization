classdef tHelioSwarmAnalysis < AnalysisTestCase
% THELIOSWARMANALYSIS Tests for HelioSwarm analysis flow.

    methods (TestMethodSetup)

        function copyDataToWorkingDirectory(testCase)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "..", "test_data", "hs"), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end
    end

    methods (Test)

        % Test that full analysis returns expected results and data format.
        function fullAnalysis(testCase)

            % Exercise.
            analysis = mag.hs.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifySubstring(analysis.ScienceFileNames, "science_packets.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames, "hk_packets.csv", "Science file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end
    end
end
