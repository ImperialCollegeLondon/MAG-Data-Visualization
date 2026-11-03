function export(this, exportType, options)

    arguments
        this (1, 1) mag.imap.Analysis
        exportType (1, 1) string {mustBeMember(exportType, "MAT")}
        options.Location (1, 1) string {mustBeFolder} = "results"
        options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
        options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
    end

    % Determine export classes.
    scienceFormat = mag.imap.out.("Science" + exportType);
    hkFormat = mag.imap.out.("HK" + exportType);

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
        cropAndExport(this.Results.copy(), period, options.Location, scienceFormat);
    end

    % Export each mode.
    for m = this.getAllModes()
        cropAndExport(m, period, options.Location, scienceFormat);
    end

    % Export I-ALiRT.
    if this.Results.HasIALiRT
        cropAndExport(this.Results.IALiRT.copy(), period, options.Location, scienceFormat);
    end

    % Export range cycling.
    rangeCycling = this.getRangeCycling();

    if ~isempty(rangeCycling)
        cropAndExport(rangeCycling, period, options.Location, scienceFormat, "Range Cycling");
    end

    % Export ramp mode.
    rampMode = this.getRampMode();

    if ~isempty(rampMode)
        cropAndExport(rampMode, period, options.Location, scienceFormat, "Ramp Mode");
    end

    % Export HK data.
    if this.Results.HasHK

        hk = this.Results.HK.copy();
        hk.crop(period);

        if any([hk.HasData])
            mag.io.export(hk, Location = options.Location, Format = hkFormat);
        end
    end
end

function cropAndExport(data, period, location, format, name)
% CROPANDEXPORT Crop data to export window, and export any data that is
% left. Cropping modifies data, so it must not be shared with the analysis.

    arguments
        data (1, 1)
        period (1, 1) timerange
        location (1, 1) string
        format (1, 1) mag.io.out.Format
        name string {mustBeScalarOrEmpty} = string.empty()
    end

    data.crop(period);

    if ~data.HasScience
        return;
    end

    if isempty(name)
        mag.io.export(data, Location = location, Format = format);
    else

        mag.io.export(data, Location = location, Format = format, ...
            FileName = compose("%s %s", datestr(data.Metadata.Timestamp, "ddmmyy-hhMM"), name) + format.Extension); %#ok<DATST>
    end
end
