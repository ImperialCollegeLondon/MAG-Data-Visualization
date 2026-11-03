classdef Field < mag.graphics.view.DualSensorField
% FIELD Show Vigil magnetic field.

    methods

        function this = Field(results, options)

            arguments
                results (1, 1) mag.vigil.Instrument
                options.?mag.vigil.view.Field
            end

            args = namedargs2cell(options);
            this@mag.graphics.view.DualSensorField(results, args{:});
        end
    end
end
