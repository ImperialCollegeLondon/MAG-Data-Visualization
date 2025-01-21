classdef ExportData < mag.mixin.SetGet
% EXPORTDATA Class for capturing data to be exported.

    properties
        % FILENAME File name where to save exported data.
        FileName (1, 1) string
        % DATA Data ready for export.
        Data
    end

    methods

        function this = ExportData(options)

            arguments
                options.?mag.io.out.ExportData
            end

            this.assignProperties(options)
        end
    end
end
