classdef Compression < mag.process.Step
% COMPRESSION Apply correction for compressed data.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % COMPRESSIONVARIABLE Name of compression variable.
        CompressionVariable (1, 1) string
        % CORRECTIONFACTOR Compression correction factor.
        CorrectionFactor (1, 1) double = 1
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

        function value = get.Name(~)
            value = "Apply Compression Correction";
        end

        function value = get.Description(this)
            value = "Apply correction to " + join(compose("""%s""", this.Variables), ", ") + " based on compression """ + this.CompressionVariable + """.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description;
        end

        function data = apply(this, data, ~)

            locCompressed = logical(data.(this.CompressionVariable));
            data{locCompressed, this.Variables} = data{locCompressed, this.Variables} / this.CorrectionFactor;
        end
    end
end
