classdef (Abstract) Writer < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% FORMAT Interface for data writers for export.

    properties (Abstract, Constant)
        % EXTENSION Extension supported for file format.
        Extension (1, 1) string
        % SUPPORTEDPROVIDERS Providers supported by writer.
        SupportedProviders (1, :) metaclass
    end

    methods (Abstract)

        % WRITE Export file to format.
        write(this, provider)
    end

    methods

        function value = isSupported(this, provider, options)
        % ISSUPPORTED Check if provider is supported.

            arguments
                this
                provider (1, 1) mag.io.out.Provider
                options.ErrorOnUnsupported (1, 1) logical = true
            end

            value = any(metaclass(provider) <= this.SupportedProviders);

            if ~value && options.ErrorOnUnsupported
                error("Provider ""%s"" is unsupported for writer ""%s"".", class(provider), class(this));
            end
        end
    end
end
