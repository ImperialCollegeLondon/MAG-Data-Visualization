classdef (Abstract) CSVWriter < mag.io.out.Format
% CSVWRITER Interface for CSV export format writers.

    properties (Constant)
        Extension = ".csv"
    end

    methods

        function write(this, fileName, exportData)

            arguments
                this (1, 1) mag.io.out.CSV
                fileName (1, 1) string
                exportData (1, 1) tabular
            end

            if istimetable(exportData)
                writetimetable(exportData, fileName);
            else
                writetable(exportData, fileName);
            end
        end
    end
end
