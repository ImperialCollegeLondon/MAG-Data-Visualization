classdef (Abstract) CDF < mag.io.out.Format
% CDF Interface for CDF export format providers.

    properties (Constant)
        Extension = ".cdf"
    end

    properties
        % SKELETONLOCATION Location of skeleton files.
        SkeletonLocation string {mustBeScalarOrEmpty, mustBeFolder}
        % LEVEL Data processing level.
        Level (1, 1) string {mag.validator.mustMatchRegex(Level, "L[0-2]\w?")} = "L1a"
        % VERSION CDF skeleton version.
        Version (1, 1) string = "V001"
    end

    methods

        function exportData = convertToExportFormat(~, data)
            exportData = data;
        end

        function write(this, fileName, exportData)

            assert(exist("spdfcdfinfo", "file"), "SPDF CDF Toolbox needs to be installed.");

            cdfInfo = spdfcdfinfo(this.getSkeletonFileName());

            spdfcdfwrite(char(fileName), ...
                this.getVariableList(cdfInfo, exportData), ...
                'GlobalAttributes', this.getGlobalAttributes(cdfInfo, exportData), ...
                'VariableAttributes', this.getVariableAttributes(cdfInfo, exportData), ...
                'WriteMode', 'overwrite', ...
                'Format', 'singlefile', ...
                'RecordBound', this.getRecordBound(cdfInfo), ...
                'CDFCompress', 'gzip.6',...
                'Checksum', 'MD5', ...
                'VarDatatypes', this.getVariableDataType(cdfInfo));
        end
    end

    methods (Abstract, Access = protected)

        % GETSKELETONFILE Get skeleton file name containing meta data.
        fileName = getSkeletonFileName(this)

        % GETGLOBALATTRIBUTES Retrieve global attributes of CDF file.
        globalAttributes = getGlobalAttributes(this, cdfInfo, data)

        % GETVARIABLEATTRIBUTES Retrieve variable attributes of CDF file.
        variableAttributes = getVariableAttributes(this, cdfInfo, data)

        % GETVARIABLEDATATYPE Retrieve variable data types of CDF file.
        variableDataTypes = getVariableDataType(this, cdfInfo)

        % GETRECORDBOUND Retrieve record bound of CDF file.
        recordBound = getRecordBound(this, cdfInfo)

        % GETVARIABLELIST Retrieve variable list of CDF file.
        variableList = getVariableList(this, cdfInfo, data)
    end
end
