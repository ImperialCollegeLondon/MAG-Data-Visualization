function loadIALiRTData(this, primarySetup, secondarySetup)
    %% Initialize

    if isempty(this.IALiRTFileNames)
        return;
    end

    this.Results.IALiRT = mag.imap.IALiRT();

    %% Import Data

    [~, ~, extension] = fileparts(this.IALiRTPattern);
    importStrategy = this.dispatchExtension(extension, "Science");

    this.Results.IALiRT.Science = mag.io.import( ...
        FileNames = this.IALiRTFileNames, ...
        Format = importStrategy, ...
        ProcessingSteps = this.PerFileProcessing);

    primary = this.Results.IALiRT.Primary;
    primary.Metadata.Setup = primarySetup;

    secondary = this.Results.IALiRT.Secondary;
    secondary.Metadata.Setup = secondarySetup;

    %% Amend Timestamp

    startTime = mag.time.emptyTime();

    if primary.HasData
        startTime(end + 1) = bounds(primary.Time);
    end

    if secondary.HasData
        startTime(end + 1) = bounds(secondary.Time);
    end

    startTime = min(startTime);

    primary.Metadata.Timestamp = startTime;
    secondary.Metadata.Timestamp = startTime;

    %% Process Data as a Whole

    for ps = this.WholeDataProcessing

        primary.Data = ps.apply(primary.Data, primary.Metadata);
        secondary.Data = ps.apply(secondary.Data, secondary.Metadata);
    end

    %% Add Mode and Range Change Events

    sensorEvents = mag.event.Event.generateEmptyEventtable();

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

    %% Remove Ramp Mode (If Any)

    if ~isempty(this.PrimaryRamp) && ~isempty(this.SecondaryRamp)

        rampTimeRange = timerange(min(this.PrimaryRamp.Time(1), this.SecondaryRamp.Time(1)), max(this.PrimaryRamp.Time(end), this.SecondaryRamp.Time(end)), "closed");

        primary.Data(rampTimeRange, :) = [];
        secondary.Data(rampTimeRange, :) = [];
    end

    %% Process I-ALiRT Data

    for is = this.IALiRTProcessing

        primary.Data = is.apply(primary.Data, primary.Metadata);
        secondary.Data = is.apply(secondary.Data, secondary.Metadata);
    end
end
