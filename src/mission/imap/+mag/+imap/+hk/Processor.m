classdef Processor < mag.HK
% PROCESSOR Class containing MAG processor HK packet data.

    properties (Dependent)
        % SINGLEBITERRORS Single bit errors in processor SRAM.
        SingleBitErrors (:, 1) double
        % MISSEDITFS Number of missed ITF frames.
        MissedITFs (:, 1) double
        % REJECTEDITFS Number of rejected ITF frames.
        RejectedITFs (:, 1) double
        % FOBQUEUENUMMSG Outboard sensor message queue.
        FOBQueueNumMSG (:, 1) double
        % FIBQUEUENUMMSG Inboard sensor message queue.
        FIBQueueNumMSG (:, 1) double
    end

    methods

        function singleBitErrors = get.SingleBitErrors(this)
            singleBitErrors = this.Data.SRAM_SINGBITERRCNT;
        end

        function missedITFs = get.MissedITFs(this)
            missedITFs = this.Data.ITF_MSD_FR;
        end

        function rejectedITFs = get.RejectedITFs(this)
            rejectedITFs = this.Data.ITF_REJ_FR;
        end

        function fobQueueNumMSG = get.FOBQueueNumMSG(this)
            fobQueueNumMSG = this.Data.OBNQ_NUM_MSG;
        end

        function fibQueueNumMSG = get.FIBQueueNumMSG(this)
            fibQueueNumMSG = this.Data.IBNQ_NUM_MSG;
        end
    end
end
