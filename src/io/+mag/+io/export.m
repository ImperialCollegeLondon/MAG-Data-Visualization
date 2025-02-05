function export(data, options)
% EXPORT Export data to specified files with specified format.

    arguments
        data (1, :)
        options.Location (1, 1) string {mustBeFolder}
        options.FileNames (1, :) string = string.empty()
        options.Format (1, 1) mag.io.out.Format
    end

    if isempty(options.FileNames)
        fileNames = options.Format.getExportFileName(data);
    else
        fileNames = options.FileNames;
    end

    fileNames = fullfile(options.Location, fileNames);
    exportData = options.Format.convertToExportFormat(data);

    options.Format.write(fileNames, exportData);
end
