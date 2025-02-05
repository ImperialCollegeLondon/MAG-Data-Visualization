classdef (Abstract) Provider < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% PROVIDER Interface for data format providers for export.

    methods (Abstract, Access = protected)

        % GETEXPORTFILENAMES Get name of export file names.
        fileNames = getExportFileNames(this, data)

        % CONVERTTOEXPORTFORMAT Convert data to an exportable format.
        [fileName, exportData] = convertToExportFormat(this, data)
    end

    methods

        function [fileNames, exportData] = getExportData(this, data)
        % GETEXPORTDATA Get data to export.

            fileNames = this.getExportFileNames(data);
            exportData = this.convertToExportFormat(data);

            assert(numel(fileNames) == numel(exportData));
        end
    end
end
