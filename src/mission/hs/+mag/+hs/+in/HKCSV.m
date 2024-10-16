classdef HKCSV < mag.io.in.CSV
% HKCSV Format HelioSwarm HK data for CSV import.

    methods

        function data = process(~, rawData, ~)

            arguments (Input)
                ~
                rawData table
                ~
            end

            arguments (Output)
                data (1, 1) mag.HK
            end

            % Convert timestamps.
            rawData.time = datetime(int64(rawData.time), ConvertFrom = "tt2000", TimeZone = "UTCLeapSeconds");
            rawData.time.TimeZone = mag.time.Constant.TimeZone;
            rawData.time.Format = mag.time.Constant.Format;

            % Convert to mag.hs.HK.
            data = mag.hs.HK(table2timetable(rawData, RowTimes = "time"), mag.meta.HK());
        end
    end
end
