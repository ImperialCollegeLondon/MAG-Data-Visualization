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
    primary.Metadata.Setup = primarySetup;

    secondary = this.Results.Secondary;
    secondary.Metadata.Setup = secondarySetup;

    %% Amend Timestamp

    [startTime, endTime] = deal(mag.time.emptyTime());

    if primary.HasData
        [startTime(end + 1), endTime(end + 1)] = bounds(primary.Time);
    end

    if secondary.HasData
        [startTime(end + 1), endTime(end + 1)] = bounds(secondary.Time);
    end

    startTime = min(startTime, [], "omitmissing");
    endTime = max(endTime, [], "omitmissing");

    primary.Metadata.Timestamp = startTime;
    secondary.Metadata.Timestamp = startTime;

    %% Add Mode and Range Change Events

    sensorEvents = eventtable(this.Results.Events);
    sensorEvents = sensorEvents(timerange(startTime - seconds(1), endTime, "closed"), :);

    if primary.HasData
        primary.Data.Properties.Events = this.generateEventTable(primary, sensorEvents);
    else
        primary.Data.Properties.Events = mag.Science.generateEmptyEventtable();
    end

    if secondary.HasData
        secondary.Data.Properties.Events = this.generateEventTable(secondary, sensorEvents);
    else
        secondary.Data.Properties.Events = mag.Science.generateEmptyEventtable();
    end

    %% Process Data as a Whole

    for wds = this.WholeDataProcessing

        primary.Data = wds.apply(primary.Data, primary.Metadata);
        secondary.Data = wds.apply(secondary.Data, secondary.Metadata);
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

        primaryRampMetadata = primary.Metadata.copy();
        secondaryRampMetadata = secondary.Metadata.copy();

        [primaryRampMetadata.DataFrequency, primaryRampMetadata.PacketFrequency] = deal(0.25, 4);
        [secondaryRampMetadata.DataFrequency, secondaryRampMetadata.PacketFrequency] = deal(0.25, 4);

        % Process ramp mode.
        for rs = this.RampProcessing

            primaryRampMode = rs.apply(primaryRampMode, primaryRampMetadata);
            secondaryRampMode = rs.apply(secondaryRampMode, secondaryRampMetadata);
        end

        % Assign ramp mode.
        this.PrimaryRamp = mag.Science(primaryRampMode, primaryRampMetadata);
        this.SecondaryRamp = mag.Science(secondaryRampMode, secondaryRampMetadata);
    end

    %% Process Science Data

    if primary.HasData

        for ss = this.ScienceProcessing
            primary.Data = ss.apply(primary.Data, primary.Metadata);
        end
    end

    if secondary.HasData

        for ss = this.ScienceProcessing
            secondary.Data = ss.apply(secondary.Data, secondary.Metadata);
        end
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
