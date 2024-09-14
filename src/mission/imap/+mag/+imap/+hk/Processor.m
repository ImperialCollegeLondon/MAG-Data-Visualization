classdef Processor < mag.HK
% PROCESSOR Class containing MAG processor HK packet data.

    properties (Dependent)
        % FOBQUEUENUMMSG Outboard sensor message queue.
        FOBQueueNumMSG (:, 1) double
        % FIBQUEUENUMMSG Inboard sensor message queue.
        FIBQueueNumMSG (:, 1) double
    end

    methods

        function fobQueueNumMSG = get.FOBQueueNumMSG(this)
            fobQueueNumMSG = this.Data.OBNQ_NUM_MSG;
        end

        function fibQueueNumMSG = get.FIBQueueNumMSG(this)
            fibQueueNumMSG = this.Data.IBNQ_NUM_MSG;
        end
    end
end
