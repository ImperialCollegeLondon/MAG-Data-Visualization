classdef (Abstract) Provider < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% PROVIDER IMAP metadata provider.

    methods (Abstract)

        % ISSUPPORTED Determine whether metadata provider is supported.
        supported = isSupported(this, fileName)

        % LOAD Load metadata.
        load(this, fileName, instrumentMetadata, primarySetup, secondarySetup)
    end
end
