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
    period = mag.time.closedTimerange(options.StartTime, options.EndTime);

    % Export full science.
    if this.Results.HasScience
        this.cropAndExport(this.Results.copy(), period, options.Location, scienceFormat);
    end

    % Export each mode.
    for m = this.getAllModes()
        this.cropAndExport(m, period, options.Location, scienceFormat);
    end

    % Export I-ALiRT.
    if this.Results.HasIALiRT
        this.cropAndExport(this.Results.IALiRT.copy(), period, options.Location, scienceFormat);
    end

    % Export range cycling.
    rangeCycling = this.getRangeCycling();

    if ~isempty(rangeCycling)
        cropAndExportNamed(rangeCycling, period, options.Location, scienceFormat, "Range Cycling");
    end

    % Export ramp mode.
    rampMode = this.getRampMode();

    if ~isempty(rampMode)
        cropAndExportNamed(rampMode, period, options.Location, scienceFormat, "Ramp Mode");
    end

    % Export HK data.
    if this.Results.HasHK
        this.cropAndExport(this.Results.HK.copy(), period, options.Location, hkFormat);
    end
end

function cropAndExportNamed(data, period, location, format, name)
% CROPANDEXPORTNAMED Crop data to export window, and export any data that
% is left to a file named after its timestamp, after cropping. Cropping
% modifies data, so it must not be shared with the analysis.

    data.crop(period);

    if data.HasScience

        mag.io.export(data, Location = location, Format = format, ...
            FileName = compose("%s %s", string(data.Metadata.Timestamp, "ddMMyy-HHmm"), name) + format.Extension);
    end
end
