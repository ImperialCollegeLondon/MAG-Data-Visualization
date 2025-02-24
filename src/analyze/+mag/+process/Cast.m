classdef Cast < mag.process.Step
% CAST Apply data type cast.

    properties
        % DATATYPE Data type to convert variables to.
        DataType (1, 1) string
        % VARIABLES Variables to be cast to different type.
        Variables (1, :) string
    end

    methods

        function this = Cast(options)

            arguments
                options.?mag.process.Cast
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            if isempty(data)
                return;
            end

            for v = this.Variables
                data.(v) = cast(data.(v), this.DataType);
            end
        end
    end
end
