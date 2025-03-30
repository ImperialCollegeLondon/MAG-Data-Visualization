classdef tBartingtonAnalysis < AnalysisTestCase
% TBARTINGTONANALYSIS Tests for Bartington analysis flow.

    properties (Access = private)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end

        function copyDataToWorkingDirectory(testCase)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "..", "test_data", "bart"), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
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

            testCase.verifyEqual(analysis.Results.Input1.Metadata.Sensor, mag.meta.Sensor.FOB, "Input 1 should be FOB.");
            testCase.verifyEqual(analysis.Results.Input2.Metadata.Sensor, mag.meta.Sensor.FIB, "Input 2 should be FIB.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end
    end
end
