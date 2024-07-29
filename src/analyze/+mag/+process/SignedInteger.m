classdef SignedInteger < mag.process.Step
% SIGNEDINTEGER Convert data to signed int16, by using the first bit as
% indicating signedness.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % COMPRESSIONVARIABLE Name of compression variable.
        CompressionVariable (1, 1) string
        % COMPRESSIONWIDTH Width of compressed data.
        CompressionWidth (1, 1) double = 16
        % VARIABLES Variables to be converted to signed integer.
        Variables (1, :) string
        % ASSUMEDTYPE Assumed type for integer conversion.
        AssumedType (1, 1) string = "int16"
    end

    methods

        function this = SignedInteger(options)

            arguments
                options.?mag.process.SignedInteger
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Change Signedness";
        end

        function value = get.Description(this)
            value = "Convert variables " + join(compose("""%s""", this.Variables), ", ") + " from unsigned to signed int16.";
        end

        function value = get.DetailedDescription(this)
            value = this.Description + " The first bit is treated as indicating signedness.";
        end

        function data = apply(this, data, ~)

            rf = rowfilter(data);

            uncompressed = rf.(this.CompressionVariable) == false;
            compressed = rf.(this.CompressionVariable) == true;

            data{uncompressed, this.Variables} = this.convertToSignedInteger(data{uncompressed, this.Variables}, 16);
            data{compressed, this.Variables} = this.convertToSignedInteger(data{compressed, this.Variables}, this.CompressionWidth);

            for v = this.Variables
                data.(v) = cast(data.(v), "double");
            end
        end
    end

    methods (Hidden)

        function signedData = convertToSignedInteger(this, unsignedData, signedBit)

            arguments (Input)
                this
                unsignedData {mustBeNumeric}
                signedBit (1, 1) double = 16
            end

            if isa(unsignedData, "double")
                assumedType = {this.AssumedType};
            else
                assumedType = {};
            end

            if isempty(unsignedData)
                signedData = unsignedData;
            else

                isNegative = bitget(unsignedData, signedBit, assumedType{:});
                signedData = bitset(unsignedData, signedBit, 0, assumedType{:}) + ((-2 ^ (signedBit - 1)) * isNegative);
            end
        end
    end
end
