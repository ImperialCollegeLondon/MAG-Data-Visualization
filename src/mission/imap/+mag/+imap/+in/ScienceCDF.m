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

            % Extract file meta data.
            [~, mode, sensor, date, ~] = this.extractFileMetaData(cdfInfo.Filename);

            % Extract raw data.
            [rawTimestamps, rawField, rawRange] = this.extractRawCDFData(rawData, cdfInfo);

            % Convert timestamps to datetime.
            timestamps = datetime(rawTimestamps, ConvertFrom = "tt2000", TimeZone = "UTCLeapSeconds");

            % Account for leap seconds.
            timestamps.TimeZone = mag.time.Constant.TimeZone;
            timestamps.Format = mag.time.Constant.Format;

            % Create science timetable.
            timedData = timetable(timestamps, (1:numel(timestamps))', ...
                rawField(:, 1), rawField(:, 2), rawField(:, 3), rawRange, ...
                false(height(timestamps), 1), 16 * ones(height(timestamps), 1), repmat(mag.meta.Quality.Regular, height(timestamps), 1), ...
                VariableNames = ["sequence", "x", "y", "z", "range", "compression", "compression_width", "quality"]);

            % Add continuity information, for simpler interpolation.
            % Property order:
            %     sequence, x, y, z, range, compression, compression width,
            %     quality
            timedData.Properties.VariableContinuity = ["step", "continuous", "continuous", "continuous", "step", "step", "step", "event"];

            % Create mag.Science object with meta data.
            metaData = mag.meta.Science(Mode = mode, Primary = isequal(sensor, mag.meta.Sensor.FOB), Sensor = sensor, ...
                Timestamp = datetime(date, InputFormat = "uuuuMMdd", Format = mag.time.Constant.Format, TimeZone = mag.time.Constant.TimeZone));
            data = mag.Science(timedData, metaData);
        end
    end

    methods (Access = private)

        function [level, mode, sensor, date, version] = extractFileMetaData(this, fileName)
        % EXTRACTMETADATA Extract meta data information from file name.

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
        end
    end
end
