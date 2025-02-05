classdef (Abstract) Format < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% FORMAT Interface for data format providers for export.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
    end

    methods (Abstract)

        % GETEXPORTFILENAME Get name of export file name.
        fileName = getExportFileName(this, data)

        % CONVERTTOEXPORTFORMAT Convert data to an exportable format.
        exportData = convertToExportFormat(this, data)

        % WRITE Export file to format.
        write(this, fileName, exportData)
    end
end
