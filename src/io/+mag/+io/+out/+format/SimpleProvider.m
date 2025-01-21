classdef (Abstract, Hidden) SimpleProvider < mag.io.out.format.Provider
% SIMPLEPROVIDER Interface for simple data format providers for export.

    methods

        function exportData = getExportData(this, data)
        % GETEXPORTDATA Get data to export.

            fileNames = this.getExportFileNames(data);
            formattedData = this.convertToExportFormat(data);

            assert(numel(fileNames) == numel(formattedData));

            for i = 1:numel(fileNames)

                exportData(i) = mag.io.out.ExportData( ...
                    FileName = fileNames(i), Data = formattedData(i)); %#ok<AGROW>
            end
        end
    end

    methods (Abstract, Access = protected)

        % GETEXPORTFILENAMES Get name of export file names.
        fileNames = getExportFileNames(this, data)

        % CONVERTTOEXPORTFORMAT Convert data to an exportable format.
        exportData = convertToExportFormat(this, data)
    end
end
