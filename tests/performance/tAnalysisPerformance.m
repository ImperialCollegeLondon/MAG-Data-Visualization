classdef (TestTags = "Performance") tAnalysisPerformance < MAGPerformanceTestCase
% TANALYSISPERFORMANCE Performance tests for end-to-end analysis of each
% mission, using system test data.

    properties (TestParameter)
        Mission = struct( ...
            Bartington = struct(Folder = "bart", Start = @(location) mag.bart.Analysis.start(Location = location)), ...
            HelioSwarm = struct(Folder = fullfile("hs", "multiple_files"), Start = @(location) mag.hs.Analysis.start(Location = location, InputSource = "iDPU")), ...
            HENON = struct(Folder = "henon", Start = @(location) mag.henon.Analysis.start(Location = location)), ...
            IMAP = struct(Folder = fullfile("imap", "full_analysis"), Start = @(location) mag.imap.Analysis.start(Location = location)), ...
            Vigil = struct(Folder = "vigil", Start = @(location) mag.vigil.Analysis.start(Location = location)))
    end

    methods (TestClassSetup)

        % Analysis may warn about data issues, which would add noise to
        % measurements.
        function suppressWarnings(testCase)

            warningState = warning("off", "all");
            testCase.addTeardown(@() warning(warningState));
        end
    end

    methods (Test)

        % Measure loading and processing of mission data.
        function start(testCase, Mission)

            location = fullfile(mag.test.DataTestUtilities.SystemTestDataLocation, Mission.Folder);
            startFcn = Mission.Start;

            testCase.startMeasuring();
            analysis = startFcn(location);
            testCase.stopMeasuring();

            testCase.verifyNotEmpty(analysis.Results, "Analysis results should not be empty.");
        end
    end
end
