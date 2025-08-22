classdef ScienceCDF < mag.io.in.CDF
% SCIENCECDF Format IMAP science data for CDF import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "imap_mag_(?<level>.+?)_(?<mode>\w+?)-mag(?<sensor>\w)_(?<date>\d+)_(?<version>.+?)\.cdf"
    end

    properties
        % CDFSETTINGS CDF file options.
        CDFSettings (1, 1) mag.io.CDFSettings
    end

    methods

        function this = ScienceCDF(options)

            arguments
                options.?mag.imap.in.ScienceCDF
            end

            this.assignProperties(options);
        end

        function data = process(this, rawData, cdfInfo)

            arguments (Input)
                this
                rawData cell
                cdfInfo (1, 1) struct
            end

            arguments (Output)
                data (1, 1) mag.Science
            end

            % Extract file metadata.
            [~, mode, sensor, date, ~] = this.extractFileMetadata(cdfInfo.Filename);

            % Extract raw data.
            [rawTimestamps, rawField, rawRange] = this.extractRawCDFData(rawData, cdfInfo);

            % Convert timestamps to datetime.
            timestamps = datetime(rawTimestamps, ConvertFrom = "tt2000", TimeZone = "UTCLeapSeconds");

            % Account for leap seconds.
            timestamps.TimeZone = mag.time.Constant.TimeZone;
            timestamps.Format = mag.time.Constant.Format;

            % Create science timetable.
            N = numel(timestamps);

            timedData = timetable(timestamps(:), (1:N)', ...
                rawField(:, 1), rawField(:, 2), rawField(:, 3), rawRange, ...
                false(N, 1), 16 * ones(N, 1), repmat(mag.meta.Quality.Regular, N, 1), ...
                VariableNames = ["sequence", "x", "y", "z", "range", "compression", "compression_width", "quality"]);
            timedData.Properties.DimensionNames(1) = "timestamps";

            % Add continuity information, for simpler interpolation.
            % Property order:
            %     sequence, x, y, z, range, compression, compression width,
            %     quality
            continuity = repmat(matlab.tabular.Continuity.unset, 1, width(timedData));
            variableNames = timedData.Properties.VariableNames;

            continuity(ismember(variableNames, ["x", "y", "z"])) = matlab.tabular.Continuity.continuous;
            continuity(ismember(variableNames, ["sequence", "range", "compression", "compression_width"])) = matlab.tabular.Continuity.step;
            continuity(ismember(variableNames, "quality")) = matlab.tabular.Continuity.event;

            timedData.Properties.VariableContinuity = continuity;

            % Create mag.Science object with metadata.
            metadata = mag.meta.Science(Mode = mode, Primary = isequal(sensor, mag.meta.Sensor.FOB), Sensor = sensor, ...
                Timestamp = datetime(date, InputFormat = "uuuuMMdd", Format = mag.time.Constant.Format, TimeZone = mag.time.Constant.TimeZone));
            data = mag.Science(timedData, metadata);
        end
    end

    methods (Access = private)

        function [level, mode, sensor, date, version] = extractFileMetadata(this, fileName)
        % EXTRACTMETADATA Extract metadata information from file name.

            details = regexp(fileName, this.FileNamePattern, "names");
            [level, date, version] = deal(details.level, details.date, details.version);

            switch lower(details.sensor)
                case "o"
                    sensor = mag.meta.Sensor.FOB;
                case "i"
                    sensor = mag.meta.Sensor.FIB;
                otherwise
                    error("Unsupported sensor ""%s"".", details.sensor);
            end

            switch details.mode
                case "burst"
                    mode = mag.meta.Mode.Burst;
                case {"normal", "norm"}
                    mode = mag.meta.Mode.Normal;
                case "ialirt"
                    mode = mag.meta.Mode.IALiRT;
                otherwise
                    error("Unsupported mode ""%s"".", details.mode);
            end
        end

        function [rawTimestamps, rawField, rawRange] = extractRawCDFData(this, rawData, cdfInfo)
        % EXTRACTRAWCDFDATA Extract raw values from CDF table.

            variableNames = cdfInfo.Variables(:, 1);

            rawTimestamps = rawData{matches(variableNames, this.CDFSettings.Timestamp, IgnoreCase = true)};

            if isequal(this.CDFSettings.Field, this.CDFSettings.Range)

                rawField = rawData{matches(variableNames, this.CDFSettings.Field, IgnoreCase = true)}(:, 1:3);
                rawRange = rawData{matches(variableNames, this.CDFSettings.Range, IgnoreCase = true)}(:, 4);
            else

                rawField = rawData{matches(variableNames, this.CDFSettings.Field, IgnoreCase = true)};
                rawRange = rawData{matches(variableNames, this.CDFSettings.Range, IgnoreCase = true)};
            end

            rawRange = mag.meta.Range(rawRange);
        end
    end
end
