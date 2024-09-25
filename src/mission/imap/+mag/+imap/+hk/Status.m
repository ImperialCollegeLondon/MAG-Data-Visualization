classdef Status < mag.HK
% STATUS Class containing MAG status HK packet data.

    properties (Dependent)
        % FOBACTIVE Outboard sensor active.
        FOBActive (:, 1) logical
        % FIBACTIVE Inboard sensor active.
        FIBActive (:, 1) logical
    end

    methods

        function fobActive = get.FOBActive(this)
            fobActive = this.Data.FOBSTAT;
        end

        function fibActive = get.FIBActive(this)
            fibActive = this.Data.FIBSTAT;
        end
    end
end
