classdef Compression < mag.process.Step
% COMPRESSION Apply correction for compressed data.

    properties
        % COMPRESSIONVARIABLE Name of compression variable.
        CompressionVariable (1, 1) string
        % COMPRESSIONWIDTHVARIABLE Name of compression width variable.
        CompressionWidthVariable (1, 1) string
        % REFERENCEWIDTH Reference width for compression correction.
        ReferenceWidth (1, 1) double = 16
        % CORRECTIONFACTOR Compression correction factor. Overrides
        % "CompressionWidthVariable".
        CorrectionFactor (1, 1) double = missing()
        % VARIABLES Variables to be corrected using compression
        % information.
        Variables (1, :) string
    end

    methods

        function this = Compression(options)

            arguments
                options.?mag.process.Compression
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            locCompressed = logical(data.(this.CompressionVariable));

            if ~ismissing(this.CorrectionFactor)
                correctionFactor = this.CorrectionFactor;
            elseif ismember(this.CompressionWidthVariable, data.Properties.VariableNames)
                correctionFactor = 2 .^ (data{locCompressed, this.CompressionWidthVariable} - this.ReferenceWidth);
            else
                correctionFactor = 1;
            end

            data{locCompressed, this.Variables} = data{locCompressed, this.Variables} ./ correctionFactor;
        end
    end
end
