classdef ScienceDAT < mag.io.in.DAT
% SCIENCEDAT Format Bartington science data for DAT import.

    properties
        % TIMEZONE Time zone for Bartington measurements.
        TimeZone (1, 1) string = "local"
    end

    methods

        function [rawData, fileName] = load(this, fileName)

            [rawData, fileName] = load@mag.io.in.DAT(this, fileName);

            if width(rawData) > 4
                rawData = rawData(:, ["Time (s)", "x (nT)", "y (nT)", "z (nT)"]);
            elseif width(rawData) < 4
                error("Bartington data should have 4 columns.");
            end
        end

        function data = process(this, rawData, fileName)

            arguments (Input)
                this (1, 1) mag.bart.in.ScienceDAT
                rawData table
                fileName (1, 1) string
            end

            arguments (Output)
                data (1, 1) mag.Science
            end

            originalVarNames = rawData.Properties.VariableNames;

            % Add start date.
            rawText = fileread(fileName);

            details = regexp(string(rawText), "Scan started at (?<hour>\d+):(?<minute>\d+):(?<second>\d+) (?<day>\d+)/(?<month>\d+)/(?<year>\d+)", "once", "names");
            details = structfun(@str2double, details, UniformOutput = false);

            startTime = datetime(details.year, details.month, details.day, details.hour, details.minute, details.second, ...
                TimeZone = this.TimeZone, Format = mag.time.Constant.Format);
            rawData.("Time (s)") = startTime + seconds(rawData.("Time (s)"));

            % Rename variables.
            rawData = renamevars(rawData, regexpPattern("\w+ \(\w+\)"), ["t", "x", "y", "z"]);
            rawData = table2timetable(rawData, RowTimes = "t");

            % Correct for units.
            units = extractBetween(string(originalVarNames{2}), "(", regexpPattern("T\)"));

            switch units
                case "u"
                    rawData{:, ["x", "y", "z"]} = rawData{:, ["x", "y", "z"]} * 1000;
                case "n"
                    % nothing to do
                otherwise
                    error("Unrecognized unit ""%s"".", units);
            end

            % Convert to science.
            inputType = extract(fileName, regexpPattern("in(?:put)? ?(\d)", IgnoreCase = true));
            inputNumber = extract(inputType, digitsPattern());

            if ~isempty(inputNumber)

                switch inputNumber
                    case "1"
                        sensor = mag.meta.Sensor.FOB;
                    case "2"
                        sensor = mag.meta.Sensor.FIB;
                    otherwise
                        sensor = mag.meta.Sensor.empty();
                end
            end

            data = mag.Science(rawData, mag.meta.Science(Sensor = sensor));
        end
    end
end
