function loadIALiRTData(this, primarySetup, secondarySetup)
    %% Initialize

    if isempty(this.IALiRTFileNames)
        return;
    end

    this.Results.IALiRT = mag.IALiRT();

    %% Import Data

    [~, ~, extension] = fileparts(this.IALiRTPattern);
    importStrategy = this.dispatchExtension(extension, "Science");

    this.Results.IALiRT.Science = mag.io.import( ...
        FileNames = this.IALiRTFileNames, ...
        Format = importStrategy, ...
        ProcessingSteps = this.PerFileProcessing);

    primary = this.Results.IALiRT.Primary;
    primary.MetaData.Setup = primarySetup;

    secondary = this.Results.IALiRT.Secondary;
    secondary.MetaData.Setup = secondarySetup;

    %% Amend Timestamp

    startTime(1) = bounds(primary.Time);
    startTime(2) = bounds(secondary.Time);

    startTime = min(startTime);

    primary.MetaData.Timestamp = startTime;
    secondary.MetaData.Timestamp = startTime;

    %% Process Data as a Whole

    for ps = this.WholeDataProcessing

        primary.Data = ps.apply(primary.Data, primary.MetaData);
        secondary.Data = ps.apply(secondary.Data, secondary.MetaData);
    end

    %% Add Mode and Range Change Events

    sensorEvents = mag.event.Event.generateEmptyEventtable();

    primary.Data.Properties.Events = this.generateEventTable(primary, sensorEvents);
    secondary.Data.Properties.Events = this.generateEventTable(secondary, sensorEvents);

    %% Remove Ramp Mode (If Any)

    if ~isempty(this.PrimaryRamp) && ~isempty(this.SecondaryRamp)

        rampTimeRange = timerange(min(this.PrimaryRamp.Time(1), this.SecondaryRamp.Time(1)), max(this.PrimaryRamp.Time(end), this.SecondaryRamp.Time(end)), "closed");

        primary.Data(rampTimeRange, :) = [];
        secondary.Data(rampTimeRange, :) = [];
    end

    %% Process I-ALiRT Data

    for is = this.IALiRTProcessing

        primary.Data = is.apply(primary.Data, primary.MetaData);
        secondary.Data = is.apply(secondary.Data, secondary.MetaData);
    end
end
