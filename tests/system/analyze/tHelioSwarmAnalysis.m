classdef (TestTags = ["System", "Parallel"]) tHelioSwarmAnalysis < AnalysisTestCase
% THELIOSWARMANALYSIS Tests for HelioSwarm analysis flow.

    methods (Test)

        % Test that single science file returns expected results and data
        % format.
        function singleFile(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("hs/single_file");

            % Exercise.
            analysis = mag.hs.Analysis.start(Location = pwd(), InputSource = "iDPU");

            % Verify.
            testCase.verifySubstring(analysis.ScienceFileNames, "science_packets.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames, "hk_packets.csv", "Science file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end

        % Test that multiple science files return expected results and data
        % format.
        function multipleFile(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("hs/multiple_files");

            % Exercise.
            analysis = mag.hs.Analysis.start(Location = pwd(), InputSource = "iDPU");

            % Verify.
            testCase.verifyThat(matlab.unittest.constraints.EveryElementOf(analysis.ScienceFileNames), matlab.unittest.constraints.Matches(".*science_packets\d\.csv"), "Science file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames, "hk_packets.csv", "Science file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end
    end
end
