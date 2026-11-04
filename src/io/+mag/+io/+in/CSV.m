classdef (Abstract) CSV < mag.io.in.Format
% CSV Interface for CSV input format providers.

    properties (Constant)
        Extension = ".csv"
    end

    methods

        function [rawData, fileName] = load(this, fileName)

            % Check there is at least one line of data in the file.
            if ~hasDataLine(fileName)

                rawData = table.empty();
                return;
            end

            dataStore = tabularTextDatastore(fileName, FileExtensions = this.Extension);
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());
        end
    end
end

function hasData = hasDataLine(fileName)
% HASDATALINE Determine whether file has a header and at least one line of
% data, by reading only the first non-empty lines.

    [fid, message] = fopen(fileName, "r");

    if fid < 0
        error("mag:io:FileNotFound", "Could not open file ""%s"": %s", fileName, message);
    end

    closeFile = onCleanup(@() fclose(fid));
    nonEmptyLines = 0;

    while nonEmptyLines < 2

        line = fgetl(fid);

        if ~ischar(line)
            break;
        elseif ~isempty(line)
            nonEmptyLines = nonEmptyLines + 1;
        end
    end

    hasData = nonEmptyLines >= 2;
end
