classdef Instrument < mag.Instrument
% INSTRUMENT Class containing Bartington instrument data.

    properties (Dependent, SetAccess = private)
        % INPUT1 Input 1 science data.
        Input1 mag.Science {mustBeScalarOrEmpty}
        % INPUT2 Input 2 science data.
        Input2 mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.imap.Instrument
            end

            this.assignProperties(options);
        end

        function input1 = get.Input1(this)
            input1 = this.Science.select("Outboard");
        end

        function input2 = get.Input2(this)
            input2 = this.Science.select("Inboard");
        end
    end
end
