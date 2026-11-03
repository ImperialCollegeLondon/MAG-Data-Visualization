classdef DualSensorInstrument < mag.Instrument
% DUALSENSORINSTRUMENT Class containing data of instrument with outboard
% and inboard sensors.

    properties (Dependent, SetAccess = private)
        % OUTBOARD Outboard (OBS) science data.
        Outboard mag.Science {mustBeScalarOrEmpty}
        % INBOARD Inboard (IBS) science data.
        Inboard mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = DualSensorInstrument(options)

            arguments
                options.?mag.DualSensorInstrument
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
