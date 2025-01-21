classdef CSV < mag.io.out.write.Writer
% CSV Writer for CSV export format.

    properties (Constant)
        Extension = ".csv"
    end

    methods

        function write(~, exportData)

            arguments
                ~
                exportData (1, 1) mag.io.out.ExportData
            end

            if istimetable(exportData)
                writetimetable(exportData, fileName);
            else
                writetable(exportData, fileName);
            end
        end
    end
end
