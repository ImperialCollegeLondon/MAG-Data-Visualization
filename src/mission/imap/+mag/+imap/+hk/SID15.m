classdef SID15 < mag.HK
% SID15 Class containing MAG SID15 HK packet data.

    properties (Dependent)
        % FOBDATAREADYTIME Outboard sensor data ready time.
        FOBDataReadyTime (:, 1) double
        % FIBDATAREADYTIME Inboard sensor data ready time.
        FIBDataReadyTime (:, 1) double
    end

    methods

        function fobDataReadyTime = get.FOBDataReadyTime(this)
            fobDataReadyTime = this.Data.ISV_FOB_DTRDYTM;
        end

        function fibDataReadyTime = get.FIBDataReadyTime(this)
            fibDataReadyTime = this.Data.ISV_FIB_DTRDYTM;
        end
    end
end
