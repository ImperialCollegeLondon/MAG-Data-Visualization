classdef ScienceCSV < mag.io.in.Format
% SCIENCECSV Format HENON science data for CSV import.

    properties (Constant)
        Extension = ".ob"
    end

    properties (Constant, Access = private)
        ScaleFactor (1, 1) double = (60000 * 2) / (2^24)
    end

    properties
        % SENSOR Sensor type (FOB or FIB).
        Sensor (1, 1) mag.meta.Sensor = mag.meta.Sensor.OBS
    end

    methods

        function this = ScienceCSV(options)

            arguments
                options.?mag.henon.in.ScienceCSV
            end

            this.assignProperties(options);
        end
    end

    methods

        function [rawData, fileName] = load(~, fileName)

            rawData = readmatrix(fileName, FileType = "text");

            if isempty(rawData)
                rawData = table.empty();
                return;
            end

            if size(rawData, 2) < 4
                error("mag:henon:InvalidScienceCSV", "Expected at least 4 CSV columns (time,bx,by,bz) in ""%s"".", fileName);
            end

            rawData = array2table(rawData(:, 1:4), VariableNames = ["time", "x", "y", "z"]);
        end

        function data = process(this, rawData, fileName)

            arguments (Input)
                this (1, 1) mag.henon.in.ScienceCSV
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, 1) mag.Science
            end

            if isempty(rawData)

                metadata = mag.meta.Science(Sensor = this.Sensor, Primary = this.Sensor == mag.meta.Sensor.OBS);
                data = mag.Science(timetable(), metadata);
                return;
            end

            timestamps = this.convertTime(rawData.time, fileName);
            numSamples = height(rawData);

            scienceData = timetable( ...
                timestamps, ...
                this.ScaleFactor * double(rawData.x), ...
                this.ScaleFactor * double(rawData.y), ...
                this.ScaleFactor * double(rawData.z), ...
                repmat(mag.meta.Range.NaN, numSamples, 1), ...
                false(numSamples, 1), ...
                repmat(mag.meta.Quality.Regular, numSamples, 1), ...
                VariableNames = ["x", "y", "z", "range", "compression", "quality"]);

            metadata = this.detectMetadata(timestamps);
            data = mag.Science(scienceData, metadata);
        end
    end

    methods (Access = private)

        function timestamps = convertTime(this, timeValues, fileName)

            timeValues = double(timeValues);

            if any(~isfinite(timeValues))
                error("mag:henon:InvalidTimeColumn", "Time column in ""%s"" contains non-finite values.", fileName);
            end

            if all(timeValues > 1e15)
                timestamps = datetime(int64(timeValues), ConvertFrom = "tt2000", TimeZone = "UTCLeapSeconds");
            elseif all(timeValues > 1e11)
                timestamps = datetime(timeValues / 1000, ConvertFrom = "posixtime", TimeZone = mag.time.Constant.TimeZone);
            elseif all(timeValues > 1e8)
                timestamps = datetime(timeValues, ConvertFrom = "posixtime", TimeZone = mag.time.Constant.TimeZone);
            elseif all(timeValues > 7e5)
                timestamps = datetime(timeValues, ConvertFrom = "datenum", TimeZone = mag.time.Constant.TimeZone);
            else

                startTime = this.detectStartTimeFromFileName(fileName);
                relativeTime = timeValues - timeValues(1);
                timestamps = startTime + seconds(relativeTime);
            end

            timestamps.TimeZone = mag.time.Constant.TimeZone;
            timestamps.Format = mag.time.Constant.Format;
        end

        function startTime = detectStartTimeFromFileName(~, fileName)

            [~, name, ~] = fileparts(fileName);

            tokens = regexp(name, "(?<date>\d{8})[_-]?(?<time>\d{6})", "names", "once");

            if isempty(tokens)
                startTime = datetime("now", TimeZone = mag.time.Constant.TimeZone);
            else
                startTime = datetime(tokens.date + tokens.time, InputFormat = "yyyyMMddHHmmss", TimeZone = mag.time.Constant.TimeZone);
            end

            startTime.Format = mag.time.Constant.Format;
        end

        function metadata = detectMetadata(this, time)

            if numel(time) < 2
                frequency = NaN;
            else
                frequency = round(1 / seconds(mode(diff(time))), 3);
            end

            metadata = mag.meta.Science( ...
                Primary = this.Sensor == mag.meta.Sensor.OBS, ...
                Sensor = this.Sensor, ...
                Mode = mag.meta.Mode.Normal, ...
                DataFrequency = frequency, ...
                Timestamp = min(time));
        end
    end
end
