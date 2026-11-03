classdef Instrument < mag.DualSensorInstrument
% INSTRUMENT Class containing Vigil instrument data.

    methods

        function this = Instrument(options)

            arguments
                options.?mag.vigil.Instrument
            end

            this.assignProperties(options);
        end
    end
end
