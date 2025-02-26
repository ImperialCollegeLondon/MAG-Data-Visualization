classdef (Abstract) Type < mag.mixin.SetGet
% TYPE Type of log format.

    properties (Abstract, Constant)
        % EXTENSIONS Extensions supported for file type.
        Extensions (1, :) string
    end

    properties
        % FILENAME File containing metadata information.
        FileName string {mustBeScalarOrEmpty, mustBeFile}
    end

    methods (Abstract)

        % LOAD Load metadata.
        [instrumentMetadata, primarySetup, secondarySetup] = load(this, instrumentMetadata, primarySetup, secondarySetup)
    end
end
