classdef Instrument < mag.DualSensorInstrument
% INSTRUMENT Class containing HENON instrument data.

    methods

        function this = Instrument(options)

            arguments
                options.?mag.henon.Instrument
            end

            this.assignProperties(options);
        end
    end
end
