classdef HKCSV < mag.imap.in.IMAPCSV
% HKCSV Format IMAP HK data for CSV import.

    properties (Constant, Access = private)
        FileNamePattern (1, 1) string = "idle_export_\w+.MAG_HSK_(?<type>\w+)_(?<date>\d+)_(?<time>\w+).(?<extension>\w+)"
    end

    properties
        % SENSORSETUP Setup for MAG sensors.
        SensorSetup (1, 2) mag.meta.Setup = repmat(mag.meta.Setup(), 1, 2)
    end

    methods

        function this = HKCSV(options)

            arguments
                options.?mag.imap.in.HKCSV
            end

            this.assignProperties(options);
        end

        function data = process(this, rawData, fileName)

            arguments (Input)
                this (1, 1) mag.imap.in.HKCSV
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, 1) mag.HK
            end

            rawData = renamevars(rawData, "SHCOARSE", "t");

            % Convert timestamps.
            for ps = [this.getTimeConversionStep()]
                rawData = ps.apply(rawData, mag.meta.HK());
            end

            % Dispatch correct type.
            data = mag.imap.hk.dispatchHKType(table2timetable(rawData, RowTimes = "t"), this.extractFileMetadata(fileName));
        end
    end

    methods (Access = private)

        function metadata = extractFileMetadata(this, fileName)
        % EXTRACTMETADATA Extract metadata information from file name.

            rawData = regexp(fileName, this.FileNamePattern, "names");

            timestamp = datetime(rawData.date + rawData.time, InputFormat = "yyyyMMddHHmmss", TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);
            metadata = mag.meta.HK(Type = rawData.type, OutboardSetup = this.SensorSetup(1), InboardSetup = this.SensorSetup(2), Timestamp = timestamp);
        end
    end
end
