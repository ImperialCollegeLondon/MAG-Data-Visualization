classdef (TestTags = ["System", "Parallel"]) tIMAPAnalysis < AnalysisTestCase
% TIMAPANALYSIS Tests for IMAP analysis flow.

    properties (TestParameter)
        CDFSensor = struct( ...
            Outboard = struct(Pattern = "o", Available = "Primary", Missing = "Secondary"), ...
            Inboard = struct(Pattern = "i", Available = "Secondary", Missing = "Primary"))
        UnequalSensor = {"Primary", "Secondary"}
    end

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
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

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

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_pwr.MAG_HSK_PW_20240507_111151.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_proc.MAG_HSK_PROCSTAT_20240507_111151.csv", "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{3}, "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{4}, "idle_export_conf.MAG_HSK_SID15_20240507_111151.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{5}, "idle_export_stat.MAG_HSK_STATUS_20240507_111151.csv", "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"), ...
                @() disp(mag.test.baselineDifference(analysis.Results, "results.mat", "results")));
        end

        % Test that analysis with FOB only returns expected results.
        function fobOnlyAnalysis(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = pwd());

            % Verify.
            testCase.verifySubstring(analysis.EventFileNames, "20250206_104029.html", "Event file names do not match.");
            testCase.verifyEmpty(analysis.MetadataFileNames, "Metadata file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "MAGScience-burst-(128,8)-2s-20250206-10h44.csv", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "MAGScience-burst-(128,8)-2s-20250206-11h51.csv", "Science file names do not match.");

            testCase.verifySubstring(analysis.IALiRTFileNames(1), "MAGScience-IALiRT-20250206-10h44.csv", "I-ALiRT file names do not match.");
            testCase.verifySubstring(analysis.IALiRTFileNames(2), "MAGScience-IALiRT-20250206-11h51.csv", "I-ALiRT file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_pwr.MAG_HSK_PW_20250206_104025.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_proc.MAG_HSK_PROCSTAT_20250206_104025.csv", "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{3}, "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{4}, "idle_export_conf.MAG_HSK_SID15_20250206_104025.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{5}, "idle_export_stat.MAG_HSK_STATUS_20250206_104025.csv", "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"), ...
                @() disp(mag.test.baselineDifference(analysis.Results, "results.mat", "results")));
        end

        % Test that analysis of S/C test returns expected results.
        function scTestAnalysis(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/sc_test");

            % Exercise.
            analysis = testCase.verifyWarning(@() mag.imap.Analysis.start(Location = pwd()), "");

            % Verify.
            testCase.verifySubstring(analysis.EventFileNames, "20250324_140003.html", "Event file names do not match.");
            testCase.verifySubstring(analysis.MetadataFileNames, "imap_setup.json", "Metadata file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "MAGScience-normal-(2,2)-32s-20250324-16h50.csv", "Science file names do not match.");
            testCase.verifyEmpty(analysis.IALiRTFileNames, "I-ALiRT file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "idle_export_pwr.MAG_HSK_PW_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "idle_export_proc.MAG_HSK_PROCSTAT_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{3}, "idle_export_sci.MAG_HSK_SCI_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{4}, "idle_export_conf.MAG_HSK_SID15_20250324_135949.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{5}, "idle_export_stat.MAG_HSK_STATUS_20250324_135949.csv", "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"), ...
                @() disp(mag.test.baselineDifference(analysis.Results, "results.mat", "results")));
        end

        % Test that analysis of L1b CDF files returns expected results.
        function l1bCDFTestAnalysis(testCase)

            testCase.assumeTrue(exist("spdfcdfinfo", "file") == 2, "SPDF CDF Toolbox not installed. Test skipped.");

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/l1b_cdf");

            options = {"Location", pwd(), ...
                "Level", mag.imap.meta.Level.L1b, ...
                "SciencePattern", fullfile("data", "science", "mag", "l1b", "*", "*", "*.cdf"), ...
                "HKPattern", fullfile("data", "hk", "mag", "l1", "*", "*", "*", "*.csv")};

            % Exercise.
            analysis = testCase.verifyWarning(@() mag.imap.Analysis.start(options{:}), "");

            % Verify.
            testCase.verifyEmpty(analysis.EventFileNames, "Event file names do not match.");
            testCase.verifySubstring(analysis.MetadataFileNames, "imap_setup.json", "Metadata file names do not match.");

            testCase.verifySubstring(analysis.ScienceFileNames(1), "imap_mag_l1b_burst-magi_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(2), "imap_mag_l1b_burst-mago_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(3), "imap_mag_l1b_norm-magi_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifySubstring(analysis.ScienceFileNames(4), "imap_mag_l1b_norm-mago_20250421_v007.cdf", "Science file names do not match.");
            testCase.verifyEmpty(analysis.IALiRTFileNames, "I-ALiRT file names do not match.");

            testCase.verifySubstring(analysis.HKFileNames{1}, "imap_mag_l1_hsk-pw_20250421_v001.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{2}, "imap_mag_l1_hsk-procstat_20250421_v001.csv", "HK file names do not match.");
            testCase.verifySubstring(analysis.HKFileNames{3}, "imap_mag_l1_hsk-sci_20250421_v001.csv", "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{4}, "HK file names do not match.");
            testCase.verifyEmpty(analysis.HKFileNames{5}, "HK file names do not match.");

            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");
            testCase.verifyEqualsBaseline(analysis.Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"), ...
                @() disp(mag.test.baselineDifference(analysis.Results, "results.mat", "results")));
        end

        % Test that analysis of L1b CDF files with data from only one
        % sensor returns empty data for the other sensor.
        function l1bCDFOneSensor(testCase, CDFSensor)

            testCase.assumeTrue(exist("spdfcdfinfo", "file") == 2, "SPDF CDF Toolbox not installed. Test skipped.");

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/l1b_cdf");

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = pwd(), ...
                Level = mag.imap.meta.Level.L1b, ...
                SciencePattern = fullfile("data", "science", "mag", "l1b", "*", "*", compose("*-mag%s_*.cdf", CDFSensor.Pattern)), ...
                HKPattern = fullfile("data", "hk", "mag", "l1", "*", "*", "*", "*.csv"));

            % Verify.
            results = analysis.Results;

            testCase.assertNumElements(results.Science, 2, "Both sensors should exist.");
            testCase.verifyEqual(results.(CDFSensor.Available).HasData, true, "Available sensor should have data.");
            testCase.verifyEqual(results.(CDFSensor.Missing).HasData, false, "Missing sensor should not have data.");
        end

        % Test that data is not split by mode when sensors have a different
        % number of modes, as they cannot be paired.
        function getAllModes_unequalModes(testCase, UnequalSensor)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());

            sensor = analysis.Results.(UnequalSensor);
            events = sensor.Data.Properties.Events;

            sensor.Data.Properties.Events = events(setdiff(1:height(events), find(~ismissing(events.Duration), 1, "last")), :);

            % Exercise.
            modes = testCase.verifyWarning(@() analysis.getAllModes(), "mag:imap:UnequalModes", "Warning should be thrown when modes differ.");

            % Verify.
            testCase.verifyEmpty(modes, "Data should not be split by mode.");
        end

        % Test that export window limits data, with modes outside of the
        % window being skipped.
        function export_timeWindow(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            timeRange = analysis.Results.TimeRange;

            exportFolder = testCase.createTemporaryFolder();

            % Exercise.
            analysis.export("MAT", Location = exportFolder, ...
                StartTime = timeRange(1) + (diff(timeRange) / 4), ...
                EndTime = timeRange(1) + (diff(timeRange) / 2));

            % Verify.
            exportedFiles = string({dir(fullfile(exportFolder, "*.mat")).name});

            testCase.verifyTrue(any(contains(exportedFiles, "Burst (64, 8)")), "Burst mode inside window should be exported.");
            testCase.verifyFalse(any(contains(exportedFiles, "Burst (128, 128)")), "Burst mode outside window should not be exported.");

            hkFile = exportedFiles(endsWith(exportedFiles, "HK.mat"));
            testCase.assertNumElements(hkFile, 1, "HK should be exported.");

            hk = load(fullfile(exportFolder, hkFile), "HK").HK;
            testCase.verifyTrue(all(isbetween(hk.PWR.Time, timeRange(1) + (diff(timeRange) / 4), timeRange(1) + (diff(timeRange) / 2))), ...
                "HK should be cropped to export window.");
        end

        % Test that export without window includes full science, each mode,
        % I-ALiRT and HK.
        function export_allData(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            exportFolder = testCase.createTemporaryFolder();

            % Exercise.
            analysis.export("MAT", Location = exportFolder);

            % Verify.
            exportedFiles = sort(string({dir(fullfile(exportFolder, "*.mat")).name}));

            testCase.verifyEqual(exportedFiles, ["070524-1014 HK.mat", "070524-1032 Hybrid (NaN, NaN).mat", "070524-1032 IALiRT (0.25, 0.25).mat", ...
                "070524-1032 Normal (2, 2).mat", "070524-1033 Burst (64, 8).mat", "070524-1034 Normal (2, 2).mat", ...
                "070524-1035 Burst (128, 128).mat", "070524-1036 Normal (2, 2).mat"], "Exported files do not match.");

            science = load(fullfile(exportFolder, "070524-1032 Hybrid (NaN, NaN).mat"), "B").B;

            testCase.verifyEqual(science.P.Time, analysis.Results.Primary.Time, "Full primary science should be exported.");
            testCase.verifyEqual(science.S.Time, analysis.Results.Secondary.Time, "Full secondary science should be exported.");
            testCase.verifyEqual(science.P.Data, analysis.Results.Primary.XYZ, "Full primary science should be exported.");

            hk = load(fullfile(exportFolder, "070524-1014 HK.mat"), "HK").HK;
            testCase.verifyEqual(sort(string(fieldnames(hk)))', ["PROCSTAT", "PWR", "SID15", "STATUS"], "All HK types should be exported.");
        end

        % Test that range cycling is exported when found.
        function export_rangeCycling(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            testCase.addRangeCycling(analysis, 7:10, 6:9);

            exportFolder = testCase.createTemporaryFolder();

            % Exercise.
            analysis.export("MAT", Location = exportFolder);

            % Verify.
            exportedFiles = string({dir(fullfile(exportFolder, "*.mat")).name});
            testCase.verifyTrue(any(endsWith(exportedFiles, "Range Cycling.mat")), "Range cycling should be exported.");
        end

        % Test that export works with only one sensor.
        function export_oneSensor(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/fob_only");

            analysis = mag.imap.Analysis.start(Location = pwd());
            exportFolder = testCase.createTemporaryFolder();

            % Exercise.
            analysis.export("MAT", Location = exportFolder);

            % Verify.
            exportedFiles = string({dir(fullfile(exportFolder, "*.mat")).name});
            testCase.verifyTrue(any(contains(exportedFiles, "Burst (128, 8)")), "Science should be exported.");
        end

        % Test that only first range cycling is returned, when there are
        % many.
        function getRangeCycling_manyOccurrences(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            testCase.addRangeCycling(analysis, [1:4, 7:10], [1:4, 6:9]);

            % Exercise.
            rangeCycling = analysis.getRangeCycling();

            % Verify.
            testCase.assertNotEmpty(rangeCycling, "Range cycling should be found.");

            testCase.verifyLessThan(rangeCycling.Primary.Time(end), analysis.Results.Primary.Events.Time(5), "Only first primary range cycling should be returned.");
            testCase.verifyLessThan(rangeCycling.Secondary.Time(end), analysis.Results.Secondary.Events.Time(5), "Only first secondary range cycling should be returned.");
        end

        % Test that range cycling can end with the last event.
        function getRangeCycling_lastEvent(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            testCase.addRangeCycling(analysis, 8:11, 7:10);

            % Exercise.
            rangeCycling = analysis.getRangeCycling();

            % Verify.
            testCase.assertNotEmpty(rangeCycling, "Range cycling should be found.");
            testCase.verifyEqual(rangeCycling.Primary.Time(end), analysis.Results.Primary.Time(end), "Range cycling should include data until the end.");
        end

        % Test that mode cycling can end with the last event.
        function getModeCycling_lastEvent(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());

            analysis.Results.Primary.Data.Properties.Events.DataFrequency(4:11) = [2; 64; 2; 4; 64; 4; 4; 128];
            analysis.Results.Secondary.Data.Properties.Events.DataFrequency(3:10) = [2; 8; 2; 1; 64; 1; 4; 128];

            % Exercise.
            modeCycling = analysis.getModeCycling();

            % Verify.
            testCase.assertNotEmpty(modeCycling, "Mode cycling should be found.");
            testCase.verifyEqual(modeCycling.Primary.Time(end), analysis.Results.Primary.Time(end), "Mode cycling should include data until the end.");
        end

        % Test that export does not change analysis results.
        function export_analysisNotModified(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            results = analysis.Results;
            timeRange = results.TimeRange;

            expectedRows = [height(results.Primary.Data), height(results.IALiRT.Primary.Data), height(results.HK(1).Data)];

            % Exercise.
            analysis.export("MAT", Location = testCase.createTemporaryFolder(), ...
                StartTime = timeRange(1) + seconds(30), ...
                EndTime = timeRange(2) - seconds(5));

            % Verify.
            actualRows = [height(results.Primary.Data), height(results.IALiRT.Primary.Data), height(results.HK(1).Data)];

            testCase.verifyEqual(actualRows, expectedRows, "Science, I-ALiRT and HK data should not change.");
        end

        % Test that nothing is exported when window does not contain data.
        function export_windowOutsideData(testCase)

            % Set up.
            testCase.copyDataToWorkingDirectory("imap/full_analysis");

            analysis = mag.imap.Analysis.start(Location = pwd());
            timeRange = analysis.Results.TimeRange;

            exportFolder = testCase.createTemporaryFolder();

            % Exercise.
            analysis.export("MAT", Location = exportFolder, ...
                StartTime = timeRange(2) + days(1), ...
                EndTime = timeRange(2) + days(2));

            % Verify.
            testCase.verifyEmpty(dir(fullfile(exportFolder, "*.mat")), "No files should be exported.");
        end

        % Test that CDF export is rejected, as it is not implemented.
        function export_cdfNotSupported(testCase)

            analysis = mag.imap.Analysis();

            testCase.verifyError(@() analysis.export("CDF", Location = pwd()), "MATLAB:validators:mustBeMember", ...
                "Error should be thrown for unsupported export format.");
        end
    end

    methods (Static, Access = private)

        function addRangeCycling(analysis, primaryEvents, secondaryEvents)
        % ADDRANGECYCLING Set ranges of events to one or more range cycling
        % patterns (3, 2, 1, 0).

            pattern = mag.meta.Range([3; 2; 1; 0]);

            analysis.Results.Primary.Data.Properties.Events.Range(primaryEvents) = repmat(pattern, numel(primaryEvents) / 4, 1);
            analysis.Results.Secondary.Data.Properties.Events.Range(secondaryEvents) = repmat(pattern, numel(secondaryEvents) / 4, 1);
        end
    end
end
