classdef Range < mag.process.Step
% RANGE Apply scale factor based on range value.

    properties
        % RANGEVARIABLE Name of range variable.
        RangeVariable (1, 1) string
        % VARIABLES Variables to be converted using range information.
        Variables (1, :) string
        % SCALEFACTORS Scale factor for each axis and supported range.
        ScaleFactors (3, 4) double {mustBePositive} = [2.13618, 0.072, 0.01854, 0.00453; 2.13618, 0.072, 0.01854, 0.00453; 2.13618, 0.072, 0.01854, 0.00453]
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
                for axis = 1:3
                    data(locScaleFactor, axis) = this.ExtraScaling * this.ScaleFactors(axis, sf + 1) * data(locScaleFactor, axis);
                end
            end
        end
    end
end
