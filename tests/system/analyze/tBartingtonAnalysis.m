classdef (TestTags = ["System", "Parallel"]) tBartingtonAnalysis < AnalysisTestCase
% TBARTINGTONANALYSIS Tests for Bartington analysis flow.

    methods (TestMethodSetup)

        function copyTestData(testCase)
            testCase.copyDataToWorkingDirectory("bart");
        end
    end

    methods (Test)

        % Test that full analysis returns expected results and data format.
        function fullAnalysis(testCase)

            % Exercise.
            analysis = mag.bart.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifySubstring(analysis.Input1FileNames, "test Input 1 bart.Dat", "Input 1 file names do not match.");
            testCase.verifySubstring(analysis.Input2FileNames, "test Input 2 bart.Dat", "Input 2 file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyEqual(analysis.Results.Input1.Metadata.Sensor, mag.meta.Sensor.OBS, "Input 1 should be OBS.");
            testCase.verifyEqual(analysis.Results.Input2.Metadata.Sensor, mag.meta.Sensor.IBS, "Input 2 should be IBS.");

            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end
    end
end
