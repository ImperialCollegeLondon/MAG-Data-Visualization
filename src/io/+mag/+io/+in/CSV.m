classdef (Abstract) CSV < mag.io.in.Format
% CSV Interface for CSV input format providers.

    properties (Constant)
        Extension = ".csv"
    end

    methods

        function [rawData, fileName] = load(this, fileName)

            % Check there is at least one line of data in the file.
            if nnz(~cellfun(@isempty, strsplit(fileread(fileName), newline))) < 2

                rawData = table.empty();
                return;
            end

            dataStore = tabularTextDatastore(fileName, FileExtensions = this.Extension);
            rawData = dataStore.readall(UseParallel = mag.internal.useParallel());
        end
    end
end
