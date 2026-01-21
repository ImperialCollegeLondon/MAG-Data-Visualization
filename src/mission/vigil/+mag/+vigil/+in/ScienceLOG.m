classdef ScienceLOG < mag.io.in.Format
% SCIENCELOG Format Vigil science data for LOG.TXT import.

    properties (Constant)
        Extension = ".txt"
    end

    properties
        % SENSOR Sensor type (FOB or FIB).
        Sensor (1, 1) mag.meta.Sensor = mag.meta.Sensor.FOB
    end

    methods

        function this = ScienceLOG(options)

            arguments
                options.?mag.vigil.in.ScienceLOG
            end

            this.assignProperties(options);
        end

        function [rawData, fileName] = load(~, fileName)

            % Read data, skipping header row.
            rawData = readtable(fileName, ...
                VariableNamingRule = "preserve", ...
                TextType = "string", ...
                Delimiter = ",");

            if isempty(rawData)
                return;
            end

            % Keep only required columns: Time, Bx, By, Bz, Range.
            % Column order is: Vector No., Time, Status, Bx, By, Bz, Range.
            rawData = rawData(:, [2, 4, 5, 6, 7]);
            rawData.Properties.VariableNames = ["Time", "Bx", "By", "Bz", "Range"];
        end

        function data = process(this, rawData, fileName)

            arguments (Input)
                this (1, 1) mag.vigil.in.ScienceLOG
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, 1) mag.Science
            end

            if isempty(rawData)
                data = mag.Science(timetable(), mag.meta.Science(Sensor = this.Sensor));
                return;
            end

            % Extract timestamp from filename.
            % Pattern: XXX_sci_yyyyMMdd_hhmmss.log.txt
            [~, name, ~] = fileparts(fileName);
            name = erase(name, ".log");

            tokens = regexp(name, "\w+_sci_(?<date>\d{8})_(?<time>\d{6})", "names", "once");

            if ~isempty(tokens)
                startTime = mag.time.decodeDate(tokens.date + tokens.time, ExtraFormats = "yyyyMMddHHmmss");
            else
                startTime = datetime("now", TimeZone = "UTC");
            end

            % Convert time column (seconds since some epoch) to datetime.
            % The time values are large numbers representing elapsed time.
            % We'll use the relative time from the first sample.
            timeValues = rawData.Time;
            relativeTime = timeValues - timeValues(1);

            % Create datetime array from relative seconds.
            timestamps = startTime + seconds(relativeTime);
            timestamps.Format = mag.time.Constant.Format;

            % Create timetable.
            scienceData = timetable(timestamps, ...
                rawData.Bx, rawData.By, rawData.Bz, rawData.Range, ...
                VariableNames = ["x", "y", "z", "range"]);

            % Create metadata.
            metadata = this.detectMetadata(timestamps);

            data = mag.Science(scienceData, metadata);
        end
    end

    methods (Access = private)

        function metadata = detectMetadata(this, time)

            dt = diff(time);
            frequency = round(1 / seconds(median(dt)), 1);

            timestamp = min(time);

            metadata = mag.meta.Science( ...
                Sensor = this.Sensor, ...
                Mode = mag.meta.Mode.Normal, ...
                DataFrequency = frequency, ...
                Timestamp = timestamp);
        end
    end
end
