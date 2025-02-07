classdef tIMAPAnalysis < matlab.unittest.TestCase
% TIMAPANALYSIS Tests for IMAP analysis flow.

    properties (Access = private)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestClassSetup)

        function skipOnGitHub(testCase)
            testCase.assumeTrue(isempty(getenv("GITHUB_ACTIONS")), "Tests cannot run on GitHub CI runner.");
        end

        function useMATLABR2024bOrAbove(testCase)
            testCase.assumeTrue(matlabRelease().Release >= "R2024b", "Only MATLAB older than R2024b is supported for this test.");
        end
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end

        function suppressWarnings(testCase)
            testCase.applyFixture(matlab.unittest.fixtures.SuppressedWarningsFixture("MATLAB:class:EnumerationValueChanged"));
        end
    end

    methods (Test)

        % Test that full analysis returns expected results.
        function fullAnalysis(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("full_analysis");

            % Exercise.
            analysis = testCase.verifyWarning(@() mag.imap.Analysis.start(Location = pwd()), "");

            % Verify.
            testCase.verifySubstring(analysis.EventFileNames, "20240507_111204.html", "Event file names do not match.");
            testCase.verifySubstring(analysis.MetaDataFileNames, "IMAP - MAG.msg", "Meta data file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "MAGScience-burst-(128,128)-2s-20240507-11h35.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "MAGScience-burst-(64,8)-4s-20240507-11h33.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(3), "MAGScience-normal-(2,2)-8s-20240507-11h33.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(4), "MAGScience-normal-(2,2)-8s-20240507-11h34.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(5), "MAGScience-normal-(2,2)-8s-20240507-11h36.csv", "Science file names do not match.");

            testCase.verifySubstring(analysis.IALiRTFileNames(1), "MAGScience-IALiRT-20240507-11h32.csv", "I-ALiRT file names do not match.");
            testCase.verifySubstring(analysis.IALiRTFileNames(2), "MAGScience-IALiRT-20240507-11h35.csv", "I-ALiRT file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_conf.MAG_HSK_SID15_20240507_111151.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_proc.MAG_HSK_PROCSTAT_20240507_111151.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{3}, "idle_export_pwr.MAG_HSK_PW_20240507_111151.csv", "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{4}, "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{5}, "idle_export_stat.MAG_HSK_STATUS_20240507_111151.csv", "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end

        % Test that analysis with FOB only returns expected results.
        function fobOnlyAnalysis(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifySubstring(analysis.EventFileNames, "20250206_104029.html", "Event file names do not match.");
            testCase.verifyEmpty(analysis.MetaDataFileNames, "Meta data file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "MAGScience-burst-(128,8)-2s-20250206-10h44.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "MAGScience-burst-(128,8)-2s-20250206-11h51.csv", "Science file names do not match.");

            testCase.verifySubstring(analysis.IALiRTFileNames(1), "MAGScience-IALiRT-20250206-10h44.csv", "I-ALiRT file names do not match.");
            testCase.verifySubstring(analysis.IALiRTFileNames(2), "MAGScience-IALiRT-20250206-11h51.csv", "I-ALiRT file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_conf.MAG_HSK_SID15_20250206_104025.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_proc.MAG_HSK_PROCSTAT_20250206_104025.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{3}, "idle_export_pwr.MAG_HSK_PW_20250206_104025.csv", "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{4}, "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{5}, "idle_export_stat.MAG_HSK_STATUS_20250206_104025.csv", "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
        end
    end

    methods (Access = private)

        function copyDataToWorkingDirectory(testCase, testFolder)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "test_data", "imap", testFolder), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end
    end
end
