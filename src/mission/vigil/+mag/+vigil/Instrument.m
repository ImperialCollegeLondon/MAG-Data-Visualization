classdef Instrument < mag.Instrument
% INSTRUMENT Class containing Vigil instrument data.

    properties (Dependent, SetAccess = private)
        % OUTBOARD Outboard (FOB) science data.
        Outboard mag.Science {mustBeScalarOrEmpty}
        % INBOARD Inboard (FIB) science data.
        Inboard mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.vigil.Instrument
            end

            this.assignProperties(options);
        end

        function outboard = get.Outboard(this)
            outboard = this.Science.select(Sensor = "OBS");
        end

        function inboard = get.Inboard(this)
            inboard = this.Science.select(Sensor = "IBS");
        end
    end
end
