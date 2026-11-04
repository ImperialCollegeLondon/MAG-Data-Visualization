classdef (TestTags = ["Unit", "Parallel"]) tIMAPAnalysis < matlab.unittest.TestCase
% TIMAPANALYSIS Unit tests for "mag.imap.Analysis" class.

    properties (TestParameter)
        AliasName = {"mag.IMAPAnalysis", "mag.IMAPTestingAnalysis", "mag.AutomatedAnalysis"}
        EmptyPattern = {struct(Name = "EventPattern", Value = string.empty(), Property = "Events"), ...
            struct(Name = "EventPattern", Value = "", Property = "Events"), ...
            struct(Name = "MetadataPattern", Value = string.empty()), ...
            struct(Name = "SciencePattern", Value = string.empty(), Property = "Science"), ...
            struct(Name = "SciencePattern", Value = "", Property = "Science"), ...
            struct(Name = "IALiRTPattern", Value = string.empty(), Property = "IALiRT"), ...
            struct(Name = "IALiRTPattern", Value = "", Property = "IALiRT"), ...
            struct(Name = "HKPattern", Value = string.empty(), Property = "HK"), ...
            struct(Name = "HKPattern", Value = "", Property = "HK")}
        ModeChange = struct( ...
            FastToSlow = struct(Times = [0:0.125:100, 101:200]', Frequencies = [8; 1]), ...
            SlowToFast = struct(Times = [0:100, 100.125:0.125:200]', Frequencies = [1; 8]))
    end

    methods (Test)

        % Test that custom processing steps are not replaced when starting
        % analysis.
        function start_customProcessing(testCase)

            % Set up.
            processing = mag.imap.Processing();

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = testCase.createTemporaryFolder(), Processing = processing);

            % Verify.
            testCase.verifySameHandle(analysis.Processing, processing, "Custom processing steps should be used.");
        end

        % Test that mode changes are found, regardless of whether cadence
        % increases or decreases.
        function findModeChanges_direction(testCase, ModeChange)

            % Set up.
            startTime = datetime(2025, 1, 1, TimeZone = "UTC");

            data = testCase.createModeData(startTime + seconds(ModeChange.Times));
            events = testCase.createModeEvents(startTime + seconds([0; 112]), ModeChange.Frequencies);

            % Exercise.
            events = mag.imap.Analysis.findModeChanges(data, events, "OBS");

            % Verify.
            testCase.verifyEqual(events.Time(2), startTime + seconds(100), "Mode change should be found at change in cadence.");
        end

        % Test that an unconventional cadence at the start of the search
        % window is ignored.
        function findModeChanges_outlierAtStartOfWindow(testCase)

            % Set up.
            startTime = datetime(2025, 1, 1, TimeZone = "UTC");

            data = testCase.createModeData(startTime + seconds([0:95, 95.7, 96.7:199]'));
            events = testCase.createModeEvents(startTime + seconds([0; 125]), [1; 8]);

            % Exercise.
            events = mag.imap.Analysis.findModeChanges(data, events, "OBS");

            % Verify.
            testCase.verifyLessThan(abs(events.Time(2) - (startTime + seconds(124.7))), milliseconds(1), "Mode change should be at closest sample to event.");
        end

        % Test that mode changes are found when the time variable is not
        % named "t", as in L1b data.
        function findModeChanges_timeVariableName(testCase)

            % Set up.
            startTime = datetime(2025, 1, 1, TimeZone = "UTC");

            data = testCase.createModeData(startTime + seconds([0:100, 100.125:0.125:200]'));
            data.Properties.DimensionNames(1) = "timestamps";

            events = testCase.createModeEvents(startTime + seconds([0; 112]), [1; 8]);

            % Exercise.
            events = mag.imap.Analysis.findModeChanges(data, events, "OBS");

            % Verify.
            testCase.verifyEqual(events.Time(1), startTime, "First mode should start with data.");
            testCase.verifyEqual(events.Time(2), startTime + seconds(100), "Mode change should be found at change in cadence.");
        end

        % Test that aliases are defined.
        function alias(testCase, AliasName)

            testCase.applyFixture(matlab.unittest.fixtures.SuppressedWarningsFixture("MATLAB:alias:AliasDeprecation"));
            testCase.verifyClass(feval(AliasName), "mag.imap.Analysis", sprintf("Alias ""%s"" should exist.", AliasName));
        end

        % Test that ramp mode timestamps are found from science data.
        function updateRampModeTimestamps(testCase)

            % Set up.
            data = testCase.createRampData(NumPatterns = 5, NumAfter = 20);

            times = data.t([5, 60]);
            events = testCase.createRampEvents(times + minutes(1), ["OBS Ramp"; "OBS Config"]);

            % Exercise.
            events = mag.imap.Analysis.updateRampModeTimestamps(events, data);

            % Verify.
            testCase.verifyEqual(events.Time(1), data.t(11), "Ramp start should be first sample of pattern.");
            testCase.verifyEqual(events.Time(2), data.t(52), "Ramp end should be first sample after last pattern.");
        end

        % Test that ramp mode can be the last event, with no event marking
        % its end.
        function updateRampModeTimestamps_lastEvent(testCase)

            % Set up.
            data = testCase.createRampData(NumPatterns = 5, NumAfter = 20);

            times = data.t([1, 5]);
            events = testCase.createRampEvents(times, ["OBS Config"; "OBS Ramp"]);

            % Exercise.
            updatedEvents = mag.imap.Analysis.updateRampModeTimestamps(events, data);

            % Verify.
            testCase.verifyEqual(updatedEvents.Time(1), events.Time(1), "Event before ramp should not change.");
            testCase.verifyEqual(updatedEvents.Time(2), data.t(11), "Ramp start should be first sample of pattern.");
        end

        % Test that ramp mode can end with the data.
        function updateRampModeTimestamps_endOfData(testCase)

            % Set up.
            data = testCase.createRampData(NumPatterns = 5, NumAfter = 0);

            times = data.t([5, end]);
            events = testCase.createRampEvents(times, ["OBS Ramp"; "OBS Config"]);

            % Exercise.
            events = mag.imap.Analysis.updateRampModeTimestamps(events, data);

            % Verify.
            testCase.verifyEqual(events.Time(2), data.t(end), "Ramp end should be last sample.");
        end

        % Test that analysis can be run with empty patterns.
        function oneEmptyPattern(testCase, EmptyPattern)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", "imap", "fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(EmptyPattern.Name, EmptyPattern.Value, Location = location);

            % Verify.
            testCase.assertNotEmpty(analysis, compose("Analysis should not be empty for pattern ""%s""", EmptyPattern.Name));

            if isfield(EmptyPattern, "Property")
                testCase.verifyEmpty(analysis.Results.(EmptyPattern.Property), compose("No %s data should be loaded with empty pattern ""%s"".", EmptyPattern.Property, EmptyPattern.Name));
            end
        end

        % Test that analysis can be run with all empty patterns.
        function allEmptyPatterns(testCase)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", "imap", "fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = location, ...
                EventPattern = string.empty(), ...
                MetadataPattern = string.empty(), ...
                SciencePattern = string.empty(), ...
                IALiRTPattern = string.empty(), ...
                HKPattern = string.empty());

            % Verify.
            testCase.assertNotEmpty(analysis, "Analysis should not be empty.");
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyEmpty(analysis.Results.Events, "Events should be empty.");
            testCase.verifyEmpty(analysis.Results.Science, "Science should be empty.");
            testCase.verifyEmpty(analysis.Results.IALiRT, "IALiRT should be empty.");
            testCase.verifyEmpty(analysis.Results.HK, "HK should be empty.");
        end
    end

    methods (Static, Access = private)

        function data = createModeData(t)
            data = timetable(t, repmat(mag.meta.Quality.Regular, numel(t), 1), VariableNames = "quality");
        end

        function data = createRampData(options)
        % CREATERAMPDATA Create data with 10 samples before ramp mode, and
        % optionally some after.

            arguments
                options.NumPatterns (1, 1) double
                options.NumAfter (1, 1) double
            end

            ramp = cumsum(repmat(mag.process.Ramp.Pattern, 1, options.NumPatterns))';
            x = [zeros(11, 1); ramp; repmat(ramp(end), options.NumAfter, 1)];

            t = datetime(2025, 1, 1, TimeZone = "UTC") + seconds(0:(numel(x) - 1))';
            data = timetable(t, x, x, x, VariableNames = ["x", "y", "z"]);
        end

        function events = createRampEvents(time, labels)

            events = timetable(labels, RowTimes = time, VariableNames = "Label");
            events.Properties.DimensionNames(1) = "Time";
        end

        function events = createModeEvents(time, frequencies)

            events = timetable(frequencies, zeros(size(frequencies)), RowTimes = time, VariableNames = ["DataFrequency", "Duration"]);
            events.Properties.DimensionNames(1) = "Time";
        end
    end
end
