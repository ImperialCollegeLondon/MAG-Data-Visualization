classdef MAT < mag.io.out.write.Writer
% MAT Writer for MAT export format.

    properties (Constant)
        Extension = ".mat"
    end

    properties
        % APPEND Append data to existing MAT file.
        Append (1, 1) logical = false
    end

    methods

        function write(this, data, provider, options)

            arguments
                this (1, 1) mag.io.out.write.MAT
                data (1, :)
                provider (1, 1) mag.io.out.format.MAT
                options.Location
                options.OverwriteFileName
            end

            if this.Append && isfile(fileName)
                extraOptions = {"-append"};
            else
                extraOptions = {};
            end

            exportData = provider.getExportData(data);

            for i = 1:numel(exportData)

                fileName = exportData(i).FileName;
                formattedData = exportData(i).Data;

                save(fileName, "-struct", "formattedData", "-mat", extraOptions{:});
            end
        end
    end
end
