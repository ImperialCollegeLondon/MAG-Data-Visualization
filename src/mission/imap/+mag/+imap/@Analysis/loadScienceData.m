function loadScienceData(this, primarySetup, secondarySetup)
    %% Initialize

    if isempty(this.ScienceFileNames)
        return;
    end

    %% Import Data

    [~, ~, extension] = fileparts(this.SciencePattern);
    importStrategy = this.dispatchExtension(extension, "Science");

    this.Results.Science = mag.io.import( ...
        FileNames = this.ScienceFileNames, ...
        Format = importStrategy, ...
        ProcessingSteps = this.PerFileProcessing);

    primary = this.Results.Primary;
    primary.MetaData.Setup = primarySetup;

    secondary = this.Results.Secondary;
    secondary.MetaData.Setup = secondarySetup;

    %% Amend Timestamp

    [startTime(1), endTime(1)] = bounds(primary.Time);
    [startTime(2), endTime(2)] = bounds(secondary.Time);

    startTime = min(startTime);
    endTime = max(endTime);

    primary.MetaData.Timestamp = startTime;
    secondary.MetaData.Timestamp = startTime;

    %% Add Mode and Range Change Events

    sensorEvents = eventtable(this.Results.Events);
    sensorEvents = sensorEvents(timerange(startTime - seconds(1), endTime, "closed"), :);

    primary.Data.Properties.Events = this.generateEventTable(primary, sensorEvents);
    secondary.Data.Properties.Events = this.generateEventTable(secondary, sensorEvents);

    %% Process Data as a Whole

    for wds = this.WholeDataProcessing

        primary.Data = wds.apply(primary.Data, primary.MetaData);
        secondary.Data = wds.apply(secondary.Data, secondary.MetaData);
    end

    %% Extract Ramp Mode (If Any)

    % Determine ramp mode times.
    primaryRampPeriod = findRampModePeriod(primary.Events);
    secondaryRampPeriod = findRampModePeriod(secondary.Events);

    primaryRampMode = primary.Data(primaryRampPeriod, :);
    secondaryRampMode = secondary.Data(secondaryRampPeriod, :);

    primary.Data(primaryRampPeriod, :) = [];
    secondary.Data(secondaryRampPeriod, :) = [];

    if ~isempty(primaryRampMode) && ~isempty(secondaryRampMode)

        primaryRampMetaData = primary.MetaData.copy();
        secondaryRampMetaData = secondary.MetaData.copy();

        [primaryRampMetaData.DataFrequency, primaryRampMetaData.PacketFrequency] = deal(0.25, 4);
        [secondaryRampMetaData.DataFrequency, secondaryRampMetaData.PacketFrequency] = deal(0.25, 4);

        % Process ramp mode.
        for rs = this.RampProcessing

            primaryRampMode = rs.apply(primaryRampMode, primaryRampMetaData);
            secondaryRampMode = rs.apply(secondaryRampMode, secondaryRampMetaData);
        end

        % Assign ramp mode.
        this.PrimaryRamp = mag.Science(primaryRampMode, primaryRampMetaData);
        this.SecondaryRamp = mag.Science(secondaryRampMode, secondaryRampMetaData);
    end

    %% Process Science Data

    for ss = this.ScienceProcessing

        primary.Data = ss.apply(primary.Data, primary.MetaData);
        secondary.Data = ss.apply(secondary.Data, secondary.MetaData);
    end
end

function period = findRampModePeriod(events)

    arguments (Input)
        events eventtable
    end

    arguments (Output)
        period (1, 1) timerange
    end

    events = events(events.Reason == "Command", :);

    idxRamp = find(contains([events.Label], "Ramp", IgnoreCase = true));
    idxRamp = vertcat(idxRamp, idxRamp + 1);

    events = events(idxRamp, :);

    if isempty(events)
        period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
    else
        period = timerange(events.Time(1), events.Time(end), "openright");
    end
end
