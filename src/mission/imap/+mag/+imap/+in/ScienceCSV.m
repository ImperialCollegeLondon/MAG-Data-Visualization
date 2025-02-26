classdef ScienceCSV < mag.io.in.CSV
% SCIENCECSV Format IMAP science data for CSV import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "MAGScience-(?<mode>\w+)-\((?<primaryFrequency>\d+),(?<secondaryFrequency>\d+)\)-(?<packetFrequency>\d+)s-(?<date>\d+)-(?<time>\w+).(?<extension>\w+)"
    end

    methods

        function data = process(this, rawData, fileName)

            arguments (Input)
                this
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, :) mag.Science
            end

            % Separate primary and secondary.
            rawPrimary = rawData(:, regexpPattern(".*(pri|sequence|compression).*"));
            rawSecondary = rawData(:, regexpPattern(".*(sec|sequence|compression).*"));

            % Extract file metadata.
            [mode, primaryFrequency, secondaryFrequency, packetFrequency, timeStamp] = this.extractFileMetadata(fileName);

            % Process science data.
            data = [this.processScience(rawPrimary, "pri", Sensor = mag.meta.Sensor.FOB, Mode = mode, DataFrequency = primaryFrequency, PacketFrequency = packetFrequency, Timestamp = timeStamp), ...
                this.processScience(rawSecondary, "sec", Sensor = mag.meta.Sensor.FIB, Mode = mode, DataFrequency = secondaryFrequency, PacketFrequency = packetFrequency, Timestamp = timeStamp)];
        end
    end

    methods (Access = private)

        function [mode, primaryFrequency, secondaryFrequency, packetFrequency, timeStamp] = extractFileMetadata(this, fileName)
        % EXTRACTMETADATA Extract metadata information from file name.

            rawData = regexp(fileName, this.FileNamePattern, "names");

            % If no metadata was found, assume default values.
            if isempty(rawData)

                timeStamp = regexp(fileName, "(?<date>\d+)-(?<time>\w+)", "names");
                timeStamp = datetime(timeStamp.date + timeStamp.time, InputFormat = "uuuuMMddHH'h'mm", TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);

                if contains(fileName, "ialirt", IgnoreCase = true)

                    mode = "IALiRT";
                    primaryFrequency = "0.25";
                    secondaryFrequency = "0.25";
                    packetFrequency = "4";
                elseif contains(fileName, "normal", IgnoreCase = true)

                    mode = "Normal";
                    primaryFrequency = "2";
                    secondaryFrequency = "2";
                    packetFrequency = "8";
                elseif contains(fileName, "burst", IgnoreCase = true)

                    mode = "Burst";
                    primaryFrequency = "128";
                    secondaryFrequency = "128";
                    packetFrequency = "2";
                else
                    error("Unrecognized file name format for ""%s"".", fileName);
                end

            % Otherwise, extract from file name.
            else

                mode = regexprep(rawData.mode, "(\w)(\w+)", "${upper($1)}$2");

                primaryFrequency = rawData.primaryFrequency;
                secondaryFrequency = rawData.secondaryFrequency;
                packetFrequency = rawData.packetFrequency;
                timeStamp = datetime(rawData.date + rawData.time, InputFormat = "uuuuMMddHH'h'mm", TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);
            end
        end

        function data = processScience(~, rawData, sensor, metadataOptions)
        % PROCESSSCIENCE Process science data.

            arguments
                ~
                rawData table
                sensor (1, 1) string {mustBeMember(sensor, ["pri", "sec"])}
                metadataOptions.?mag.meta.Science
            end

            metadataArgs = namedargs2cell(metadataOptions);
            metadata = mag.meta.Science(metadataArgs{:}, Primary = isequal(sensor, "pri"));

            % Rename variables.
            newVariableNames = ["x", "y", "z", "range", "coarse", "fine"];
            rawData = renamevars(rawData, [["x", "y", "z", "rng"] + "_" + sensor, sensor + "_" + ["coarse", "fine"]], newVariableNames);

            % Add compression and quality flags.
            if ismember("compression", rawData.Properties.VariableNames)
                rawData.compression = logical(rawData.compression);
            else
                rawData.compression = false(height(rawData), 1);
            end

            if ismember("compression_width_bits", rawData.Properties.VariableNames)

                rawData.compression_width = double(rawData.compression_width_bits);
                rawData = removevars(rawData, "compression_width_bits");
            else
                rawData.compression_width = 16 * ones(height(rawData), 1);
            end

            rawData.quality = repmat(mag.meta.Quality.Regular, height(rawData), 1);

            % Convert timestamps.
            for ps = [mag.process.Missing(Variables = ["x", "y", "z"]), mag.process.Timestamp(), mag.process.Spice(Mission = "IMAP")]
                rawData = ps.apply(rawData, metadata);
            end

            % Add continuity information, for simpler interpolation.
            % Property order:
            %     sequence, x, y, z, range, coarse, fine, compression,
            %     compression width, quality, t
            rawData.Properties.VariableContinuity = ["step", "continuous", "continuous", "continuous", "step", ...
                "continuous", "continuous", "step", "step", "event", "continuous"];

            % Convert to mag.Science.
            data = mag.Science(table2timetable(rawData, RowTimes = "t"), metadata);
        end
    end
end
