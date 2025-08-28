classdef SignedInteger < mag.process.Step
% SIGNEDINTEGER Convert data to signed int16, by using the first bit as
% indicating signedness.

    properties
        % INGORECOMPRESSEDDATA Flag to ignore compressed data.
        IgnoreCompressedData (1, 1) logical = true
        % COMPRESSIONVARIABLE Name of compression variable.
        CompressionVariable (1, 1) string
        % COMPRESSIONWIDTHVARIABLE Name of compression width variable.
        CompressionWidthVariable (1, 1) string
        % REFERENCEWIDTH Compression reference width. Overrides
        % "CompressionWidthVariable".
        ReferenceWidth (1, 1) double = missing()
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

        function data = apply(this, data, ~)

            rf = rowfilter(data);

            uncompressed = rf.(this.CompressionVariable) == false;
            data{uncompressed, this.Variables} = this.convertToSignedInteger(data{uncompressed, this.Variables}, 16);

            if ~this.IgnoreCompressedData

                compressed = rf.(this.CompressionVariable) == true;

                if ismissing(this.ReferenceWidth)
                    signedBit = data{compressed, this.CompressionWidthVariable};
                else
                    signedBit = this.ReferenceWidth;
                end

                try
                    data{compressed, this.Variables} = this.convertToSignedInteger(data{compressed, this.Variables}, signedBit);
                catch exception

                    if ~ismember(exception.identifier, "MATLAB:bitget:outOfRange")
                        exception.rethrow();
                    end
                end
            end

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
