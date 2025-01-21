classdef CDF < mag.io.out.provide.Provider
% CDF Interface for CDF format data provider.

    properties (Constant)
        Writer = mag.io.out.write.CDF()
    end

    properties
        % SKELETONLOCATION Location of skeleton files.
        SkeletonLocation string {mustBeScalarOrEmpty, mustBeFolder}
        % LEVEL Data processing level.
        Level (1, 1) string {mag.validator.mustMatchRegex(Level, "L[0-2]\w?")} = "L1a"
        % VERSION CDF skeleton version.
        Version (1, 1) string = "V001"
    end

    methods (Abstract)

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
