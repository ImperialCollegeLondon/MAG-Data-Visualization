function export(this, exportType, options)

    arguments
        this (1, 1) mag.imap.Analysis
        exportType (1, 1) string {mustBeMember(exportType, ["MAT", "CDF"])}
        options.Location (1, 1) string {mustBeFolder} = "results"
        options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
        options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
    end

    % Determine export classes.
    scienceFormat = feval("mag.io.out.Science" + exportType);
    hkFormat = feval("mag.io.out.HK" + exportType);

    % Determine export window.
    if ismissing(options.StartTime)
        options.StartTime = datetime("-Inf", TimeZone = "UTC");
    end

    if ismissing(options.EndTime)
        options.EndTime = datetime("Inf", TimeZone = "UTC");
    end

    period = timerange(options.StartTime, options.EndTime, "closed");

    % Export full science.
    if this.Results.HasScience

        results = this.Results.copy();
        results.crop(period);

        mag.io.export(results, Location = options.Location, Format = scienceFormat);
    end

    % Export each mode.
    modes = this.getAllModes();

    for m = modes

        m.crop(period);
        mag.io.export(m, Location = options.Location, Format = scienceFormat);
    end

    % Export I-ALiRT.
    iALiRT = this.Results.IALiRT;

    if ~isempty(iALiRT)

        iALiRT.crop(period);
        mag.io.export(iALiRT, Location = options.Location, Format = scienceFormat);
    end

    % Export range cycling.
    rangeCycling = this.getRangeCycling();

    if ~isempty(rangeCycling)

        mag.io.export(rangeCycling, Location = options.Location, Format = scienceFormat, ...
            FileName = compose("%s Range Cycling", datestr(rangeCycling.MetaData.Timestamp, "ddmmyy-hhMM")) + scienceFormat.Extension); %#ok<DATST>
    end

    % Export ramp mode.
    rampMode = this.getRampMode();

    if ~isempty(rampMode)

        mag.io.export(rampMode, Location = options.Location, Format = scienceFormat, ...
            FileName = compose("%s Ramp Mode", datestr(rampMode.MetaData.Timestamp, "ddmmyy-hhMM")) + scienceFormat.Extension); %#ok<DATST>
    end

    % Export HK data.
    if ~isempty(this.Results.HK)

        hk = this.Results.HK.copy();
        hk.crop(period);

        mag.io.export(hk, Location = options.Location, Format = hkFormat);
    end
end


