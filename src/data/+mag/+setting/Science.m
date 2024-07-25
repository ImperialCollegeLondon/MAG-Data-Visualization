classdef Science < mag.mixin.SetGet
% SCIENCE Mapping of science properties from "timetable" to "mag.Science".

    properties
        % X Name of x-axis property.
        X (1, 1) string = "x"
        % Y Name of y-axis property.
        Y (1, 1) string = "y"
        % Z Name of z-axis property.
        Z (1, 1) string = "z"
        % RANGE Name of range property.
        Range (1, 1) string = "range"
        % SEQUENCE Name of sequence property.
        Sequence (1, 1) string = "sequence"
        % COMPRESSION Name of compression flag property.
        Compression (1, 1) string = "compression"
        % COMPRESSIONWIDTH Name of compression width property.
        CompressionWidth (1, 1) string = "compression_width"
        % QUALITY Name of quality flag property.
        Quality (1, 1) string = "quality"
    end

    methods

        function this = Science(options)

            arguments
                options.?mag.setting.Science
            end

            this.assignProperties(options);
        end
    end
end
