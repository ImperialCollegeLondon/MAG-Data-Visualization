classdef SID15 < mag.HK
% SID15 Class containing MAG SID15 HK packet data.

    properties (Dependent)
        % FOBATTEMPTS Outboard sensor failed activation attempts.
        FOBAttempts (:, 1) double
        % FIBATTEMPTS Inboard sensor failed activation attempts.
        FIBAttempts (:, 1) double
        % FOBACTIVE Outboard sensor active.
        FOBActive (:, 1) logical
        % FIBACTIVE Inboard sensor active.
        FIBActive (:, 1) logical
        % FOBDATAREADYTIME Outboard sensor data ready time.
        FOBDataReadyTime (:, 1) double
        % FIBDATAREADYTIME Inboard sensor data ready time.
        FIBDataReadyTime (:, 1) double
    end

    methods

        function fobAttempts = get.FOBAttempts(this)
            fobAttempts = this.Data.ISV_FOB_ACTTRIES;
        end

        function fibAttempts = get.FIBAttempts(this)
            fibAttempts = this.Data.ISV_FIB_ACTTRIES;
        end

        function fobActive = get.FOBActive(this)
            fobActive = this.getActivationStatus("ICV_FOB_ISACT");
        end

        function fibActive = get.FIBActive(this)
            fibActive = this.getActivationStatus("ICV_FIB_ISACT");
        end

        function fobDataReadyTime = get.FOBDataReadyTime(this)
            fobDataReadyTime = this.Data.ISV_FOB_DTRDYTM;
        end

        function fibDataReadyTime = get.FIBDataReadyTime(this)
            fibDataReadyTime = this.Data.ISV_FIB_DTRDYTM;
        end
    end

    methods (Access = private)

        function status = getActivationStatus(this, fieldName)

            if ismember(fieldName, this.Data.Properties.VariableNames)

                status = this.Data.(fieldName);
                status(ismissing(status)) = 0;

                status = logical(status);
            else
                status = repmat(missing(), height(this.Data), 1);
            end
        end
    end
end
