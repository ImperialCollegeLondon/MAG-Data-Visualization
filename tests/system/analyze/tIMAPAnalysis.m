classdef tIMAPAnalysis < AnalysisTestCase
% TIMAPANALYSIS Tests for IMAP analysis flow.

    methods (TestClassSetup)

        function checkMICEToolbox(testCase)
            testCase.assumeTrue(exist("mice", "file") == 3, "MICE Toolbox not installed. Test skipped.");
        end
    end

    methods (TestMethodSetup)

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
            testCase.verifySubstring(analysis.MetadataFileNames, "IMAP - MAG.msg", "Metadata file names do not match.");

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

            if mag.test.isGitHub()
                testCase.log("Skip comparison with baseline on GitHub CI runner.");
            else
                testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
            end
        end

        % Test that analysis with FOB only returns expected results.
        function fobOnlyAnalysis(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifySubstring(analysis.EventFileNames, "20250206_104029.html", "Event file names do not match.");
            testCase.verifyEmpty(analysis.MetadataFileNames, "Metadata file names do not match.");

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

            if mag.test.isGitHub()
                testCase.log("Skip comparison with baseline on GitHub CI runner.");
            else
                testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
            end
        end

        % Test that analysis of S/C test returns expected results.
        function scTestAnalysis(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("sc_test");

            % Exercise.
            analysis = testCase.verifyWarning(@() mag.imap.Analysis.start(Location = pwd()), "");

            % Verify.
            testCase.verifySubstring(analysis.EventFileNames, "20250324_140003.html", "Event file names do not match.");
            testCase.verifySubstring(analysis.MetadataFileNames, "imap_setup.json", "Metadata file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "MAGScience-normal-(2,2)-32s-20250324-16h50.csv", "Science file names do not match.");
            testCase.verifyEmpty(analysis.IALiRTFileNames, "I-ALiRT file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_conf.MAG_HSK_SID15_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_proc.MAG_HSK_PROCSTAT_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{3}, "idle_export_pwr.MAG_HSK_PW_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{4}, "idle_export_sci.MAG_HSK_SCI_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{5}, "idle_export_stat.MAG_HSK_STATUS_20250324_135949.csv", "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            if mag.test.isGitHub()
                testCase.log("Skip comparison with baseline on GitHub CI runner.");
            else
                testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
            end
        end

        % Test that analysis of L1b CDF files returns expected results.
        function l1bCDFTestAnalysis(testCase)

            testCase.assumeTrue(exist("spdfcdfinfo", "file") == 2, "SPDF CDF Toolbox not installed. Test skipped.");

            % Set up.
            testCase.copyDataToWorkingDirectory("l1b_cdf");

            options = {"Location", pwd(), ...
                "Level", mag.imap.meta.Level.L1b, ...
                "SciencePattern", fullfile("data", "imap", "mag", "l1b", "*", "*", "*.cdf")};

            % Exercise.
            analysis = mag.imap.Analysis.start(options{:});

            % Verify.
            testCase.verifyEmpty(analysis.EventFileNames, "Event file names do not match.");
            testCase.verifySubstring(analysis.MetadataFileNames, "imap_setup.json", "Metadata file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "imap_mag_l1b_burst-magi_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "imap_mag_l1b_burst-mago_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(3), "imap_mag_l1b_norm-magi_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(4), "imap_mag_l1b_norm-mago_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifyEmpty(analysis.IALiRTFileNames, "I-ALiRT file names do not match.");

            testCase.verifyEmpty(analysis.HKFileNames{1}, "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{2}, "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{3}, "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{4}, "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{5}, "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            if mag.test.isGitHub()
                testCase.log("Skip comparison with baseline on GitHub CI runner.");
            else
                testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
            end
        end
    end

    methods (Access = private)

        function copyDataToWorkingDirectory(testCase, testFolder)

            [status, message] = copyfile(fullfile(testCase.WorkingDirectory.StartingFolder, "..", "test_data", "imap", testFolder), fullfile(testCase.WorkingDirectory.Folder));
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end
    end
end
