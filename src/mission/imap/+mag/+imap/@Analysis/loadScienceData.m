function loadScienceData(this, primarySetup, secondarySetup)
% LOADSCIENCEDATA Load science and I-ALiRT data. Science data is loaded
% first, as I-ALiRT data excludes its ramp mode.

    loadScience(this, primarySetup, secondarySetup);
    loadIALiRT(this, primarySetup, secondarySetup);
end

function loadScience(this, primarySetup, secondarySetup)

    if isempty(this.ScienceFileNames)
        return;
    end

    this.Results.Science = importSensors(this, this.ScienceFileNames, this.SciencePattern, primarySetup, secondarySetup);
    sensors = [this.Results.Primary, this.Results.Secondary];

    [startTime, endTime] = amendTimestamp(sensors);

    % Add mode and range change events from logs. Events are added before
    % processing the data as a whole, unlike for I-ALiRT data.
    sensorEvents = eventtable(this.Results.Events);
    sensorEvents = sensorEvents(timerange(startTime - seconds(1), endTime, "closed"), :);

    addEventTables(this, sensors, sensorEvents);
    applySteps(this.Processing.WholeDataSteps, sensors);

    % Extract ramp mode (if any), before processing science data.
    [this.PrimaryRamp, this.SecondaryRamp] = extractRampMode(sensors, this.Processing.RampSteps);

    applySteps(this.Processing.ScienceSteps, sensors([sensors.HasData]));
end

function loadIALiRT(this, primarySetup, secondarySetup)

    if isempty(this.IALiRTFileNames)
        return;
    end

    this.Results.IALiRT = mag.imap.IALiRT();
    this.Results.IALiRT.Science = importSensors(this, this.IALiRTFileNames, this.IALiRTPattern, primarySetup, secondarySetup);

    sensors = [this.Results.IALiRT.Primary, this.Results.IALiRT.Secondary];

    amendTimestamp(sensors);

    % I-ALiRT data has no events from logs, so mode changes are found
    % from the data, after processing it as a whole.
    applySteps(this.Processing.WholeDataSteps, sensors);
    addEventTables(this, sensors, mag.event.Event.generateEmptyEventtable());

    % Remove ramp mode (if any), found in science data.
    if ~isempty(this.PrimaryRamp) && ~isempty(this.SecondaryRamp)

        rampTimeRange = timerange(min(this.PrimaryRamp.Time(1), this.SecondaryRamp.Time(1)), max(this.PrimaryRamp.Time(end), this.SecondaryRamp.Time(end)), "closed");

        for s = sensors
            s.Data(rampTimeRange, :) = [];
        end
    end

    applySteps(this.Processing.IALiRTSteps, sensors);
end

function science = importSensors(this, fileNames, pattern, primarySetup, secondarySetup)
% IMPORTSENSORS Import data for both sensors, and assign their setup.

    [~, ~, extension] = fileparts(pattern);
    importStrategy = this.dispatchExtension(extension, "Science");

    science = this.addMissingSensor(mag.io.import( ...
        FileNames = fileNames, ...
        Format = importStrategy, ...
        ProcessingSteps = this.Processing.PerFileSteps));

    primary = science.select(Primary = true);
    primary.Metadata.Setup = primarySetup;

    secondary = science.select(Primary = false);
    secondary.Metadata.Setup = secondarySetup;
end

function [startTime, endTime] = amendTimestamp(sensors)
% AMENDTIMESTAMP Set timestamp of both sensors to the earliest time of
% either sensor.

    sensorsWithData = sensors([sensors.HasData]);
    [startTime, endTime] = deal(NaT(size(sensorsWithData), TimeZone = mag.time.Constant.TimeZone));

    for i = 1:numel(sensorsWithData)
        [startTime(i), endTime(i)] = bounds(sensorsWithData(i).Time);
    end

    startTime = min(startTime, [], "omitmissing");
    endTime = max(endTime, [], "omitmissing");

    for s = sensors
        s.Metadata.Timestamp = startTime;
    end
end

function addEventTables(this, sensors, sensorEvents)
% ADDEVENTTABLES Add mode and range change events to each sensor.

    for s = sensors

        if s.HasData
            s.Data.Properties.Events = this.generateEventTable(s, sensorEvents);
        else
            s.Data.Properties.Events = mag.Science.generateEmptyEventtable();
        end
    end
end

function applySteps(steps, sensors)
% APPLYSTEPS Apply processing steps to each sensor.

    for s = sensors
        for ps = steps
            s.Data = ps.apply(s.Data, s.Metadata);
        end
    end
end

function [primaryRamp, secondaryRamp] = extractRampMode(sensors, rampSteps)
% EXTRACTRAMPMODE Remove ramp mode from science data, and process it
% separately. Ramp mode is only kept if both sensors have it.

    rampData = cell(size(sensors));

    for i = 1:numel(sensors)

        period = findRampModePeriod(sensors(i).Events);

        rampData{i} = sensors(i).Data(period, :);
        sensors(i).Data(period, :) = [];
    end

    if any(cellfun(@isempty, rampData))

        [primaryRamp, secondaryRamp] = deal(mag.Science.empty());
        return;
    end

    ramps = mag.Science.empty();

    for i = 1:numel(sensors)

        metadata = sensors(i).Metadata.copy();
        [metadata.DataFrequency, metadata.PacketFrequency] = deal(0.25, 4);

        for rs = rampSteps
            rampData{i} = rs.apply(rampData{i}, metadata);
        end

        ramps(i) = mag.Science(rampData{i}, metadata);
    end

    [primaryRamp, secondaryRamp] = deal(ramps(1), ramps(2));
end

function period = findRampModePeriod(events)
% FINDRAMPMODEPERIOD Find period between ramp mode command and the next
% command.

    arguments (Input)
        events eventtable
    end

    arguments (Output)
        period (1, 1) timerange
    end

    events = events(events.Reason == "Command", :);
    idxRamp = mag.imap.Analysis.findRampEvents(events);

    if isempty(idxRamp)
        period = mag.time.emptyTimerange();
    else
        period = timerange(events.Time(idxRamp(1)), events.Time(idxRamp(end)), "openright");
    end
end
