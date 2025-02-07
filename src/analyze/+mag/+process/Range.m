classdef Range < mag.process.Step
% RANGE Apply scale factor based on range value.

    properties (Constant)
        % SCALEFACTORS Scale factor for each supported range.
        ScaleFactors (1, 4) double = [2.13618, 0.072, 0.01854, 0.00453]
    end

    properties
        % RANGEVARIABLE Name of range variable.
        RangeVariable (1, 1) string
        % VARIABLES Variables to be converted using range information.
        Variables (1, :) string
        % EXTRASCALING Extra scaling factor.
        ExtraScaling (1, 1) double = 1
    end

    methods

        function this = Range(options)

            arguments
                options.?mag.process.Range
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            data = convertvars(data, this.Variables, "double");
            data{:, this.Variables} = this.applyRange(data{:, this.Variables}, data.(this.RangeVariable));
        end
    end

    methods (Hidden)

        function data = applyRange(this, data, ranges)

            arguments (Input)
                this
                data (:, :) double
                ranges (:, 1) double
            end

            for sf = 0:3

                locScaleFactor = ranges == sf;
                data(locScaleFactor, :) = this.ExtraScaling * this.ScaleFactors(sf + 1) * data(locScaleFactor, :);
            end
        end
    end
end
