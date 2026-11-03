classdef (TestTags = ["Unit", "Parallel"]) tIMAPEvents < matlab.unittest.TestCase
% TIMAPEVENTS Unit tests for loading events in "mag.imap.Analysis" class,
% based on excerpts of event logs.

    properties (Constant)
        % NORMALMODE Normal mode command, with acknowledgment, mode
        % transition and completion.
        NormalMode (:, 1) string = [ ...
            "<font color=""darkcyan"">2024/05/07 10:32:51:CMD  :: MAG_M_NORM(OPCODE=71, PUS_SECHDRFLAG=0, PUS_VERSION=0, PUS_ACK=9, PUS_STYPE=226, PUS_SSUBTYPE=5, NORMPRI_RATE=HZ_2, NORMSEC_RATE=HZ_2, NORM_PKTSECS=SECS_8, BRSTPRI_RATE=HZ_64, BRSTSEC_RATE=HZ_8, BRST_PKTSECS=SECS_4)</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:32:51:TLM  :: MAG_TCA_SUCC [1058, 1, 1] (All data =[0, 0, 1, 1058, 3, 3, 13, 452773956, 0, 1, 0, 1, 1,"
            "2024/05/07 10:32:51:TLM  ::   7164, 49157, 71, 226, 5])</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:32:52:TLM  :: MAG_PROG_MTRAN [1024, 5, 1] (All data =[0, 0, 1, 1024, 3, 1, 11, 452773957, 0, 1, 0, 5, 1,"
            "2024/05/07 10:32:52:TLM  ::   2, 3, 5, 2])</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:32:52:TLM  :: MAG_TCC_SUCC [1059, 1, 7] (All data =[0, 0, 1, 1059, 3, 1, 13, 452773957, 0, 1, 0, 1, 7,"
            "2024/05/07 10:32:52:TLM  ::   7164, 49157, 71, 226, 5])</font><br>"]
        % BURSTMODE Burst mode command with unchanged rates, with
        % acknowledgment, mode transition and completion.
        BurstMode (:, 1) string = [ ...
            "<font color=""darkcyan"">2024/05/07 10:33:49:CMD  :: MAG_M_BURST(OPCODE=69, PUS_SECHDRFLAG=0, PUS_VERSION=0, PUS_ACK=9, PUS_STYPE=226, PUS_SSUBTYPE=6, NORMPRI_RATE=UNCHANGED, NORMSEC_RATE=UNCHANGED, NORM_PKTSECS=UNCHANGED, BRSTPRI_RATE=UNCHANGED, BRSTSEC_RATE=UNCHANGED, BRST_PKTSECS=UNCHANGED, BRST_DURATION=30)</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:33:50:TLM  :: MAG_TCA_SUCC [1058, 1, 1] (All data =[0, 0, 1, 1058, 3, 14, 13, 452774015, 0, 1, 0, 1, 1,"
            "2024/05/07 10:33:50:TLM  ::   7164, 49170, 69, 226, 6])</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:33:51:TLM  :: MAG_PROG_MTRAN [1024, 5, 1] (All data =[0, 0, 1, 1024, 3, 2, 11, 452774016, 0, 1, 0, 5, 1,"
            "2024/05/07 10:33:51:TLM  ::   2, 5, 6, 2])</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:33:51:TLM  :: MAG_TCC_SUCC [1059, 1, 7] (All data =[0, 0, 1, 1059, 3, 13, 13, 452774016, 0, 1, 0, 1, 7,"
            "2024/05/07 10:33:51:TLM  ::   7164, 49170, 69, 226, 6])</font><br>"]
        % SECONDBURSTMODE Burst mode command, with acknowledgment only.
        SecondBurstMode (:, 1) string = [ ...
            "<font color=""darkcyan"">2024/05/07 10:35:32:CMD  :: MAG_M_BURST(OPCODE=69, PUS_SECHDRFLAG=0, PUS_VERSION=0, PUS_ACK=9, PUS_STYPE=226, PUS_SSUBTYPE=6, NORMPRI_RATE=UNCHANGED, NORMSEC_RATE=UNCHANGED, NORM_PKTSECS=UNCHANGED, BRSTPRI_RATE=HZ_128, BRSTSEC_RATE=HZ_128, BRST_PKTSECS=SECS_2, BRST_DURATION=30)</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:35:33:TLM  :: MAG_TCA_SUCC [1058, 1, 1] (All data =[0, 0, 1, 1058, 3, 31, 13, 452774118, 0, 1, 0, 1, 1,"
            "2024/05/07 10:35:33:TLM  ::   7164, 49187, 69, 226, 6])</font><br>"]
        % CONFIGMODE Config mode command, with arguments without names.
        ConfigMode (:, 1) string = [ ...
            "<font color=""darkcyan"">2025/02/06 10:43:08:CMD  :: MAG_M_CONF(80, 0, 0, 9, 226, 3)</font><br>"
            "<font color=""darkcyan"">2025/02/06 10:43:11:TLM  :: MAG_TCA_SUCC [1058, 1, 1] (All data =[0, 0, 1, 1058, 3, 3, 13, 476534582, 0, 1, 0, 1, 1,"
            "2025/02/06 10:43:11:TLM  ::   7164, 49156, 80, 226, 3])</font><br>"
            "<font color=""darkcyan"">2025/02/06 10:43:12:TLM  :: MAG_PROG_MTRAN [1024, 5, 1] (All data =[0, 0, 1, 1024, 3, 2, 11, 476534583, 0, 1, 0, 5, 1,"
            "2025/02/06 10:43:12:TLM  ::   2, 2, 3, 2])</font><br>"
            "<font color=""darkcyan"">2025/02/06 10:43:12:TLM  :: MAG_TCC_SUCC [1059, 1, 7] (All data =[0, 0, 1, 1059, 3, 3, 13, 476534583, 0, 1, 0, 1, 7,"
            "2025/02/06 10:43:12:TLM  ::   7164, 49156, 80, 226, 3])</font><br>"]
        % RANGECHANGE Range change command for FIB, with acknowledgment
        % and completion.
        RangeChange (:, 1) string = [ ...
            "<font color=""darkcyan"">2024/05/07 10:34:26:CMD  :: MAG_FEE_FIBRNG(OPCODE=23, PUS_SECHDRFLAG=0, PUS_VERSION=0, PUS_ACK=9, PUS_STYPE=227, PUS_SSUBTYPE=2, RANGE_ID=RANGE2, RANGE_GAINX=GAIN3, RANGE_GAINY=GAIN3, RANGE_GAINZ=GAIN3)</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:34:27:TLM  :: MAG_TCA_SUCC [1058, 1, 1] (All data =[0, 0, 1, 1058, 3, 17, 13, 452774052, 0, 1, 0, 1, 1,"
            "2024/05/07 10:34:27:TLM  ::   7164, 49173, 23, 227, 2])</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:34:28:TLM  :: MAG_TCC_SUCC [1059, 1, 7] (All data =[0, 0, 1, 1059, 3, 16, 13, 452774053, 0, 1, 0, 1, 7,"
            "2024/05/07 10:34:28:TLM  ::   7164, 49173, 23, 227, 2])</font><br>"]
        % OTHERCOMMAND Command that is not converted to an event.
        OtherCommand (:, 1) string = [ ...
            "<font color=""darkcyan"">2024/05/07 10:34:22:CMD  :: MAG_AR_ICU_DS(OPCODE=6, PUS_SECHDRFLAG=0, PUS_VERSION=0, PUS_ACK=9, PUS_STYPE=227, PUS_SSUBTYPE=4, SENSOR_ID=IBSENSOR)</font><br>"
            "<font color=""darkcyan"">2024/05/07 10:34:23:TLM  :: MAG_TCA_SUCC [1058, 1, 1] (All data =[0, 0, 1, 1058, 3, 15, 13, 452774048, 0, 1, 0, 1, 1,"
            "2024/05/07 10:34:23:TLM  ::   7164, 49171, 6, 227, 4])</font><br>"]
    end

    methods (Test)

        % Test that normal mode command is converted to event, with
        % response times from spacecraft time.
        function normalMode(testCase)

            % Exercise.
            events = testCase.loadEvents(testCase.NormalMode);

            % Verify.
            testCase.assertClass(events, "mag.event.ModeChange", "Normal mode should be converted to mode change.");
            testCase.assertNumElements(events, 1, "Only one event should be loaded.");

            testCase.verifyEqual(events.Mode, mag.meta.Mode.Normal, "Mode does not match.");
            testCase.verifyEqual([events.Type, events.SubType], [226, 5], "Type and sub-type do not match.");
            testCase.verifyEqual([events.PrimaryNormalRate, events.SecondaryNormalRate, events.PacketNormalFrequency], [2, 2, 8], "Normal mode rates do not match.");
            testCase.verifyEqual([events.PrimaryBurstRate, events.SecondaryBurstRate, events.PacketBurstFrequency], [64, 8, 4], "Burst mode rates do not match.");

            % Spacecraft time is 15 s behind ground time, so command time
            % is corrected. Mode transition time is not.
            testCase.verifyEqual(events.CommandTimestamp, testCase.utc(2024, 5, 7, 10, 32, 36), "Command time should be corrected to spacecraft time.");
            testCase.verifyEqual(events.AcknowledgeTimestamp, testCase.utc(2024, 5, 7, 10, 32, 36), "Acknowledgment time should be spacecraft time.");
            testCase.verifyEqual(events.CompleteTimestamp, testCase.utc(2024, 5, 7, 10, 32, 37), "Completion time should be spacecraft time.");
            testCase.verifyEqual(events.ModeChangeTimestamp, testCase.utc(2024, 5, 7, 10, 32, 52), "Mode transition time should be ground time.");
        end

        % Test that unchanged rates are missing, except for first mode
        % change, which uses default rates.
        function burstMode_unchangedRates(testCase)

            % Exercise.
            events = testCase.loadEvents([testCase.NormalMode; testCase.BurstMode]);

            % Verify.
            testCase.assertNumElements(events, 2, "Two events should be loaded.");

            burst = events(2);

            testCase.verifyEqual(burst.Mode, mag.meta.Mode.Burst, "Mode does not match.");
            testCase.verifyEqual([burst.Type, burst.SubType], [226, 6], "Type and sub-type do not match.");
            testCase.verifyEqual(burst.Duration, 30, "Duration does not match.");
            testCase.verifyEqual([burst.PrimaryBurstRate, burst.SecondaryBurstRate, burst.PacketBurstFrequency], NaN(1, 3), "Unchanged rates should be missing.");
            testCase.verifyEqual(burst.ModeChangeTimestamp, testCase.utc(2024, 5, 7, 10, 33, 51), "Mode transition should match burst mode.");
        end

        % Test that first mode change uses default rates when unchanged.
        function burstMode_defaultRates(testCase)

            % Exercise.
            events = testCase.loadEvents(testCase.BurstMode);

            % Verify.
            testCase.assertNumElements(events, 1, "Only one event should be loaded.");

            testCase.verifyEqual([events.PrimaryNormalRate, events.SecondaryNormalRate, events.PacketNormalFrequency], [2, 2, 32], "Default normal mode rates should be used.");
            testCase.verifyEqual([events.PrimaryBurstRate, events.SecondaryBurstRate, events.PacketBurstFrequency], [64, 8, 4], "Default burst mode rates should be used.");
        end

        % Test that config mode command with arguments without names is
        % converted to event.
        function configMode(testCase)

            % Exercise.
            events = testCase.loadEvents(testCase.ConfigMode);

            % Verify.
            testCase.assertClass(events, "mag.event.ModeChange", "Config mode should be converted to mode change.");
            testCase.assertNumElements(events, 1, "Only one event should be loaded.");

            testCase.verifyEqual(events.Mode, mag.meta.Mode.Config, "Mode does not match.");
            testCase.verifyEqual([events.Type, events.SubType], [226, 3], "Type and sub-type do not match.");
            testCase.verifyEqual(events.ModeChangeTimestamp, testCase.utc(2025, 2, 6, 10, 43, 12), "Mode transition should match config mode.");
            testCase.verifyEqual(events.AcknowledgeTimestamp, testCase.utc(2025, 2, 6, 10, 43, 2), "Acknowledgment time should be spacecraft time.");
            testCase.verifyEqual(events.CompleteTimestamp, testCase.utc(2025, 2, 6, 10, 43, 3), "Completion time should be spacecraft time.");
        end

        % Test that range change command is converted to event.
        function rangeChange(testCase)

            % Exercise.
            events = testCase.loadEvents(testCase.RangeChange);

            % Verify.
            testCase.assertClass(events, "mag.event.RangeChange", "Range change should be converted to range change.");
            testCase.assertNumElements(events, 1, "Only one event should be loaded.");

            testCase.verifyEqual(events.Range, mag.meta.Range.Two, "Range does not match.");
            testCase.verifyEqual(events.Sensor, mag.meta.Sensor.IBS, "Sensor does not match.");
            testCase.verifyEqual([events.Type, events.SubType], [227, 2], "Type and sub-type do not match.");
            testCase.verifyEqual(events.AcknowledgeTimestamp, testCase.utc(2024, 5, 7, 10, 34, 12), "Acknowledgment time should be spacecraft time.");
            testCase.verifyEqual(events.CompleteTimestamp, testCase.utc(2024, 5, 7, 10, 34, 13), "Completion time should be spacecraft time.");
        end

        % Test that responses to other commands are ignored.
        function responsesToOtherCommands(testCase)

            % Exercise.
            events = testCase.loadEvents([testCase.OtherCommand; testCase.RangeChange]);

            % Verify.
            testCase.assertNumElements(events, 1, "Other commands should not be converted to events.");
            testCase.verifyEqual(events.AcknowledgeTimestamp, testCase.utc(2024, 5, 7, 10, 34, 12), "Response to other command should be ignored.");
        end

        % Test that responses to a later command of the same type are not
        % used, when a command has no response.
        function responsesToLaterCommand(testCase)

            % Set up.
            lines = [testCase.NormalMode; testCase.BurstMode(1); testCase.SecondBurstMode];

            % Exercise.
            events = testCase.loadEvents(lines);

            % Verify.
            testCase.assertNumElements(events, 3, "Three events should be loaded.");

            firstBurst = events(2);

            testCase.verifyEqual(firstBurst.CommandTimestamp, testCase.utc(2024, 5, 7, 10, 33, 49), "Command time should not be corrected without responses.");
            testCase.verifyEqual(firstBurst.AcknowledgeTimestamp, firstBurst.CommandTimestamp, "Acknowledgment time should default to command time.");
            testCase.verifyEqual(firstBurst.Timestamp, firstBurst.CommandTimestamp, "Event time should default to command time.");

            testCase.verifyEqual(events(3).AcknowledgeTimestamp, testCase.utc(2024, 5, 7, 10, 35, 18), "Later command should use its own response.");
        end

        % Test that events are loaded from all files, and sorted by time.
        function manyFiles(testCase)

            % Exercise.
            events = testCase.loadEvents(testCase.RangeChange, testCase.NormalMode);

            % Verify.
            testCase.assertNumElements(events, 2, "Events from all files should be loaded.");

            testCase.verifyClass(events(1), "mag.event.ModeChange", "Events should be sorted by time.");
            testCase.verifyClass(events(2), "mag.event.RangeChange", "Events should be sorted by time.");
        end

        % Test that no events are loaded when log contains no commands.
        function noCommands(testCase)

            % Exercise.
            events = testCase.loadEvents("<font color=""darkcyan"">2024/05/07 10:11:51:LOG  :: New Logfile Started</font><br>");

            % Verify.
            testCase.verifyEmpty(events, "No events should be loaded.");
        end
    end

    methods (Access = private)

        function events = loadEvents(testCase, varargin)
        % LOADEVENTS Write each set of lines to an event log file, and load
        % events from them.

            location = testCase.createTemporaryFolder();
            eventFolder = fullfile(location, "20240507", "Event");

            mkdir(eventFolder);

            for i = 1:numel(varargin)
                writelines(varargin{i}, fullfile(eventFolder, compose("log_%d.html", i)));
            end

            analysis = mag.imap.Analysis.start(Location = location, ...
                MetadataPattern = string.empty(), ...
                SciencePattern = string.empty(), ...
                IALiRTPattern = string.empty(), ...
                HKPattern = string.empty());

            events = analysis.Results.Events;
        end
    end

    methods (Static, Access = private)

        function time = utc(varargin)
            time = datetime(varargin{:}, TimeZone = "UTC", Format = "yyyy/MM/dd HH:mm:ss");
        end
    end
end
