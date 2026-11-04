function loadEventsData(this)
% LOADEVENTSDATA Load events from event logs, and match them to their
% responses to find when they were acknowledged and completed.

    commands = readCommands(this.EventFileNames);

    if isempty(commands)
        return;
    end

    % Convert commands to events. Mode transitions only apply to mode
    % changes, so they are added before other events.
    events = convertModeChanges(commands);
    addModeTransitions(events, commands);

    events = [events, convertSensorCommands(commands)];

    % Correct command times based on responses, and sort.
    addResponseTimes(events, commands);
    events = sort(events);

    setDefaultRates(events);

    % Concentrate on recorded timerange.
    if ~isempty(events) && ~isempty(this.Results.Metadata) && ~ismissing(this.Results.Metadata.Timestamp)
        events = events([events.Timestamp] > this.Results.Metadata.Timestamp);
    end

    this.Results.Events = events;
end

function commands = readCommands(fileNames)
% READCOMMANDS Read commands and telemetry from event logs, with their
% timestamps.

    rawEvents = string.empty();

    for ef = fileNames

        contents = extractFileText(ef);
        rawEvents = join([rawEvents, contents], newline);
    end

    rawEvents = regexp(rawEvents, "(?<timestamp>\d+/\d+/\d+ \d+:\d+:\d+):(?<category>\w+) :: (?<command>\w+)(?: \[\d+, \d+, \d+\] )?\((?<details>.*?)\)", "names", "dotexceptnewline", "lineanchors");

    if isempty(rawEvents)

        commands = struct.empty();
        return;
    end

    timestamps = num2cell(datetime([rawEvents.timestamp], InputFormat = getEventTimeFormat(), Format = getEventTimeFormat(), TimeZone = "UTC"));
    [rawEvents.timestamp] = timestamps{:};

    commands = rawEvents;
end

function events = convertModeChanges(commands)
% CONVERTMODECHANGES Convert config, normal and burst mode commands to
% mode change events.

    modeChangeFormat = ", NORMPRI_RATE=(?<primaryNormal>HZ_\d+|\w+), NORMSEC_RATE=(?<secondaryNormal>HZ_\d+|\w+), NORM_PKTSECS=(?<packetsNormal>SECS_\d+|\w+), BRSTPRI_RATE=(?<primaryBurst>HZ_\d+|\w+), BRSTSEC_RATE=(?<secondaryBurst>HZ_\d+|\w+), BRST_PKTSECS=(?<packetsBurst>SECS_\d+|\w+)";

    % Each mode is converted in turn. Config mode has no rates or
    % duration, so they are missing. Otherwise, properties not in the
    % command keep their default value.
    modes = struct(Command = {"MAG_M_CONF", "MAG_M_NORM", "MAG_M_BURST"}, ...
        Mode = {"Config", "Normal", "Burst"}, ...
        Format = {"", modeChangeFormat, modeChangeFormat + ", BRST_DURATION=(?<duration>\d+)"});

    % Map from command details to event properties.
    detailProperties = dictionary( ...
        primaryNormal = "PrimaryNormalRate", ...
        secondaryNormal = "SecondaryNormalRate", ...
        packetsNormal = "PacketNormalFrequency", ...
        primaryBurst = "PrimaryBurstRate", ...
        secondaryBurst = "SecondaryBurstRate", ...
        packetsBurst = "PacketBurstFrequency", ...
        duration = "Duration");

    events = mag.event.Event.empty();

    for m = modes

        for c = commands([commands.command] == m.Command)

            details = regexp(c.details, getCommonFormat() + m.Format, "once", "names");
            details = structfun(@(x) replace(x, ["SECS_", "HZ_", "UNCHANGED"], ["", "", "NaN"]), details, UniformOutput = false);

            args = struct(CommandTimestamp = c.timestamp, Type = details.type, SubType = details.subtype, Mode = m.Mode);

            for k = detailProperties.keys()'

                if m.Mode == "Config"
                    args.(detailProperties(k)) = missing();
                elseif isfield(details, k)
                    args.(detailProperties(k)) = details.(k);
                end
            end

            args = namedargs2cell(args);
            events(end + 1) = mag.event.ModeChange(args{:}); %#ok<AGROW>
        end
    end
end

function addModeTransitions(events, commands)
% ADDMODETRANSITIONS Assign mode transition times to the latest mode
% change commanded before them.

    if isempty(events)
        return;
    end

    modes = double([events.Mode]);
    commandTimes = [events.CommandTimestamp];

    for t = commands([commands.command] == "MAG_PROG_MTRAN")

        details = regexp(t.details, getResponsePattern(t.details), "names", "once");

        if isempty(details)
            continue;
        end

        matchingEvents = events((modes == str2double(details.curr)) & (commandTimes <= t.timestamp));

        if ~isempty(matchingEvents)

            matchingEvents = sort(matchingEvents);

            % Otherwise, it could be an automated transition.
            if ismissing(matchingEvents(end).ModeChangeTimestamp)
                matchingEvents(end).ModeChangeTimestamp = t.timestamp;
            end
        end
    end
end

function events = convertSensorCommands(commands)
% CONVERTSENSORCOMMANDS Convert range change and ramp mode commands to
% events.

    rangeChangeFormat = ", RANGE_ID=RANGE(?<range>\d+), RANGE_GAINX=GAIN(?<x>\d+), RANGE_GAINY=GAIN(?<y>\d+), RANGE_GAINZ=GAIN(?<z>\d+)";

    events = mag.event.Event.empty();

    for c = commands(matches([commands.command], regexpPattern("MAG_FEE_F(O|I)BRNG")))

        details = regexp(c.details, getCommonFormat() + rangeChangeFormat, "once", "names");
        events(end + 1) = mag.event.RangeChange( ...
            CommandTimestamp = c.timestamp, ...
            Type = details.type, ...
            SubType = details.subtype, ...
            Range = str2double(details.range), ...
            Sensor = getSensor(c.command)); %#ok<AGROW>
    end

    for c = commands(matches([commands.command], regexpPattern("MAG_FEE_F(O|I)BRAMP_EN")))

        details = regexp(c.details, getCommonFormat(), "once", "names");
        events(end + 1) = mag.event.RampMode( ...
            CommandTimestamp = c.timestamp, ...
            Type = details.type, ...
            SubType = details.subtype, ...
            Sensor = getSensor(c.command)); %#ok<AGROW>
    end
end

function addResponseTimes(events, commands)
% ADDRESPONSETIMES Assign acknowledgment and completion times, from
% spacecraft time, and correct command times to spacecraft time.

    acknowledgments = parseResponses(commands([commands.command] == "MAG_TCA_SUCC"));
    completions = parseResponses(commands([commands.command] == "MAG_TCC_SUCC"));

    % Gather properties once, as gathering them for each event is slow.
    % Command times are kept up to date as they are corrected.
    types = [events.Type];
    subTypes = [events.SubType];
    commandTimes = [events.CommandTimestamp];

    for i = 1:numel(events)

        e = events(i);

        % Ignore responses to subsequent commands of the same type.
        idxNext = find((types == types(i)) & (subTypes == subTypes(i)) & (commandTimes > commandTimes(i)), 1);

        if isempty(idxNext)
            nextCommandTime = datetime("Inf", TimeZone = "UTC");
        else
            nextCommandTime = commandTimes(idxNext);
        end

        [acknowledgeTime, acknowledgeCorrection] = matchResponse(acknowledgments, e, nextCommandTime, e.CommandTimestamp);

        if ~isempty(acknowledgeTime)
            e.AcknowledgeTimestamp = acknowledgeTime;
        end

        [completeTime, completeCorrection] = matchResponse(completions, e, nextCommandTime, e.AcknowledgeTimestamp);

        if ~isempty(completeTime)
            e.CompleteTimestamp = completeTime;
        end

        correction = [acknowledgeCorrection, completeCorrection];

        if ~isempty(correction) && any(isfinite(correction))

            e.CommandTimestamp = e.CommandTimestamp + mean(correction, "omitmissing");
            commandTimes(i) = e.CommandTimestamp;
        end
    end
end

function responses = parseResponses(rawResponses)
% PARSERESPONSES Extract spacecraft time, and type and sub-type of the
% command responded to. Responses that do not identify their command
% are dropped.

    responses = struct(timestamp = NaT(0, 1, TimeZone = "UTC"), coarse = NaT(0, 1, TimeZone = "UTC"), ...
        type = double.empty(0, 1), subtype = double.empty(0, 1));

    if isempty(rawResponses)
        return;
    end

    % Pattern is selected based on first response only.
    details = regexp([rawResponses.details], getResponsePattern(rawResponses(1).details), "names", "once");

    if ~iscell(details)
        details = {details};
    end

    locMatched = ~cellfun(@isempty, details);

    if ~any(locMatched) || ~all(isfield(details{find(locMatched, 1)}, ["type", "subtype"]))
        return;
    end

    details = [details{locMatched}];

    timestamps = [rawResponses.timestamp]';

    responses = struct(timestamp = timestamps(locMatched), ...
        coarse = datetime(mag.time.Constant.Epoch + str2double([details.coarse]'), ConvertFrom = "posixtime", Format = getEventTimeFormat(), TimeZone = mag.time.Constant.TimeZone), ...
        type = str2double([details.type]'), subtype = str2double([details.subtype]'));
end

function [responseTime, correction] = matchResponse(responses, event, nextCommandTime, fallbackTime)
% MATCHRESPONSE Find first response to event, before the next similar
% command. Return empty if there are no responses after the command, and
% the fallback time if none of them match.

    correction = duration.empty();
    locAfter = responses.timestamp >= event.CommandTimestamp;

    if ~any(locAfter)

        responseTime = datetime.empty();
        return;
    end

    idxMatch = find(locAfter & (responses.timestamp < nextCommandTime) & (responses.type == event.Type) & (responses.subtype == event.SubType), 1);

    if isempty(idxMatch)
        responseTime = fallbackTime;
    else

        responseTime = responses.coarse(idxMatch);
        correction = responses.coarse(idxMatch) - responses.timestamp(idxMatch);
    end
end

function setDefaultRates(events)
% SETDEFAULTRATES Use default rates for unchanged rates of the first
% normal or burst mode, as previous rates are unknown.

    defaults = dictionary( ...
        PrimaryNormalRate = 2, ...
        SecondaryNormalRate = 2, ...
        PacketNormalFrequency = 32, ...
        PrimaryBurstRate = 64, ...
        SecondaryBurstRate = 8, ...
        PacketBurstFrequency = 4);

    for e = events

        if isa(e, "mag.event.ModeChange") && ismember(e.Mode, [mag.meta.Mode.Burst, mag.meta.Mode.Normal])

            for k = defaults.keys'

                if ismissing(e.(k))
                    e.(k) = defaults(k);
                end
            end

            return;
        end
    end
end

function sensor = getSensor(command)
    sensor = regexp(command, "F(O|I)B", "once", "match");
end

function format = getCommonFormat()
    format = "(?:OPCODE=)?(?<opcode>\d+), (?:PUS_SECHDRFLAG=)?(?<header>\d+), (?:PUS_VERSION=)?(?<version>\d+), (?:PUS_ACK=)?(?<ack>\d+), (?:PUS_STYPE=)?(?<type>\d+), (?:PUS_SSUBTYPE=)?(?<subtype>\d+)";
end

function format = getEventTimeFormat()
    format = "yyyy/MM/dd HH:mm:ss";
end

function responsePattern = getResponsePattern(response)

    switch count(response, ",")
        case 14
            responsePattern = "All data =\[\d+, \d+, \d+, \d+, \d+, \d+, \d+, (?<coarse>\d+), \d+, \d+, \d+, \d+, \d+, (?:\d+/\d+/\d+ \d+:\d+:\d+:\w+ :: )?\d+, \d+\]";
        case 16
            responsePattern = "All data =\[\d+, \d+, \d+, \d+, \d+, \d+, \d+, (?<coarse>\d+), \d+, \d+, \d+, \d+, (?:[\w\/: ]+ :: )?\d+, (?:[\w\/: ]+ :: )?(?<event>\d+), (?<prev>\d+), (?<curr>\d+), (?<trans>\d+)\]";
        case 17
            responsePattern = "All data =\[\d+, \d+, \d+, \d+, \d+, \d+, \d+, (?<coarse>\d+), \d+, \d+, \d+, \d+, \d+, (?:\d+/\d+/\d+ \d+:\d+:\d+:\w+ :: )?\d+, \d+, \d+, (?<type>\d+), (?<subtype>\d+)\]";
        otherwise
            error("mag:imap:UnrecognizedResponse", "Unrecognized number of commas in response message.");
    end
end
