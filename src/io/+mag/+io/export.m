function export(data, options)
% EXPORT Export data to specified files with specified format.

    arguments
        data (1, :)
        options.Location (1, 1) string {mustBeFolder}
        options.FileName string {mustBeScalarOrEmpty} = string.empty()
        options.Format (1, 1) mag.io.out.Format
    end

    if isempty(options.FileName)
        fileName = options.Format.getExportFileName(data);
    else
        fileName = options.FileName;
    end

    fileName = fullfile(options.Location, fileName);
    exportData = options.Format.convertToExportFormat(data);

    options.Format.write(fileName, exportData);
end
