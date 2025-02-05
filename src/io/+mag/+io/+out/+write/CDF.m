classdef CDF < mag.io.out.write.Writer
% CDF Interface for CDF export format writers.

    properties (Constant)
        Extension = ".cdf"
    end

    methods

        function write(~, provider)

            arguments
                ~
                provider (1, 1) mag.io.out.provide.CDF
            end

            assert(exist("spdfcdfinfo", "file"), "SPDF CDF Toolbox needs to be installed.");

            [fileNames, exportData] = provider.getExportData();

            for i = 1:numel(fileNames)

                cdfInfo = spdfcdfinfo(provider.getSkeletonFileName());

                spdfcdfwrite(char(fileNames(i)), ...
                    provider.getVariableList(cdfInfo, exportData(i)), ...
                    'GlobalAttributes', provider.getGlobalAttributes(cdfInfo, exportData(i)), ...
                    'VariableAttributes', provider.getVariableAttributes(cdfInfo, exportData(i)), ...
                    'WriteMode', 'overwrite', ...
                    'Format', 'singlefile', ...
                    'RecordBound', provider.getRecordBound(cdfInfo), ...
                    'CDFCompress', 'gzip.6',...
                    'Checksum', 'MD5', ...
                    'VarDatatypes', provider.getVariableDataType(cdfInfo));
            end
        end
    end
end
