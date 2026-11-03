classdef Field < mag.graphics.view.DualSensorField
% FIELD Show Bartington magnetic field.

    methods

        function this = Field(results, options)

            arguments
                results (1, 1) mag.bart.Instrument
                options.?mag.bart.view.Field
            end

            args = namedargs2cell(options);
            this@mag.graphics.view.DualSensorField(results, args{:});

            this.SensorNames = ["Input 1", "Input 2"];
            this.TitlePrefix = "Bartington";
        end
    end
end
