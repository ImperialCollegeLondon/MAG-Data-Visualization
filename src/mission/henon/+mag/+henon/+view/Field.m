classdef Field < mag.graphics.view.DualSensorField
% FIELD Show HENON magnetic field.

    methods

        function this = Field(results, options)

            arguments
                results (1, 1) mag.henon.Instrument
                options.?mag.henon.view.Field
            end

            args = namedargs2cell(options);
            this@mag.graphics.view.DualSensorField(results, args{:});
        end
    end
end
