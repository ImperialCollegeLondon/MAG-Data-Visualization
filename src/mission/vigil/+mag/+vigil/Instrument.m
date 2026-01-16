classdef Instrument < mag.Instrument
% INSTRUMENT Class containing Vigil instrument data.

    properties (Dependent, SetAccess = private)
        % FOB FOB (outboard) science data.
        FOB mag.Science {mustBeScalarOrEmpty}
        % FIB FIB (inboard) science data.
        FIB mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.vigil.Instrument
            end

            this.assignProperties(options);
        end

        function fob = get.FOB(this)
            fob = this.Science.select(Sensor = "FOB");
        end

        function fib = get.FIB(this)
            fib = this.Science.select(Sensor = "FIB");
        end
    end
end
