classdef (Abstract) Type < mag.mixin.SetGet
% TYPE Type of log format.

    properties (Abstract, Constant)
        % EXTENSIONS Extensions supported for file type.
        Extensions (1, :) string
    end

    properties
        % FILENAME File containing meta data information.
        FileName string {mustBeScalarOrEmpty, mustBeFile}
    end

    methods (Abstract, Hidden)

        % LOAD Load meta data.
        [instrumentMetaData, primarySetup, secondarySetup] = load(this, instrumentMetaData, primarySetup, secondarySetup)
    end
end
