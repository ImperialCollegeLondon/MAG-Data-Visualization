classdef Instrument < mag.DualSensorInstrument
% INSTRUMENT Class containing Bartington instrument data. Input 1 is
% stored as the outboard sensor, and input 2 as the inboard sensor.

    properties (Dependent, SetAccess = private)
        % INPUT1 Input 1 science data.
        Input1 mag.Science {mustBeScalarOrEmpty}
        % INPUT2 Input 2 science data.
        Input2 mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.bart.Instrument
            end

            this.assignProperties(options);
        end

        function input1 = get.Input1(this)
            input1 = this.Outboard;
        end

        function input2 = get.Input2(this)
            input2 = this.Inboard;
        end
    end
end
