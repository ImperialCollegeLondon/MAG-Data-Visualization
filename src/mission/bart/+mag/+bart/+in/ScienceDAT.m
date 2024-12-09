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

            if width(rawData) > 4
                rawData = rawData(:, ["Time (s)", "x (nT)", "y (nT)", "z (nT)"]);
            elseif width(rawData) < 4
                error("Bartington data should have 4 columns.");
            end
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

            originalVarNames = rawData.Properties.VariableNames;

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
            data = mag.Science(rawData, mag.meta.Science());
        end
    end
end
