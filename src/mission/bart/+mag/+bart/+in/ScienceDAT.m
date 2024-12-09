classdef ScienceDAT < mag.io.in.DAT
% SCIENCEDAT Format Bartington science data for DAT import.

    methods

        function [rawData, fileName] = load(~, fileName)

            % Check there is at least one line of data in the file.
            if nnz(~cellfun(@isempty, strsplit(fileread(fileName), newline))) < 2

                rawData = table.empty();
                return;
            end

            % Get start date.
            rawText = fileread(fileName);

            details = regexp(string(rawText), "Scan started at (?<hour>\d+):(?<minute>\d+):(?<second>\d+) (?<day>\d+)/(?<month>\d+)/(?<year>\d+)", "once", "names");
            details = structfun(@str2double, details, UniformOutput = false);

            startTime = datetime(details.year, details.month, details.day, details.hour, details.minute, details.second, TimeZone = "local", Format = mag.time.Constant.Format);

            % Get data.
            rawData = readtable(fileName, VariableNamingRule = "preserve", TextType = "string");
            rawData.("Time (s)") = startTime + seconds(rawData.("Time (s)"));

            assert(width(rawData) == 4, "Bartington data should have 4 columns.");
        end

        function data = process(~, rawData, ~)

            arguments (Input)
                ~
                rawData table
                ~
            end

            arguments (Output)
                data (1, 1) mag.Science
            end

            data = renamevars(rawData, regexpPattern("\w+ \(\w+\)"), ["t", "x", "y", "z"]);
            data = table2timetable(data, RowTimes = "t");

            % Correct for units.
            originalVarNames = rawData.Properties.VariableNames;
            units = extractBetween(string(originalVarNames{2}), "(", regexpPattern("T\)"));

            switch units
                case "u"
                    data{:, ["x", "y", "z"]} = data{:, ["x", "y", "z"]} * 1000;
                case "n"
                    % nothing to do
                otherwise
                    error("Unrecognized unit ""%s"".", units);
            end
        end
    end
end
