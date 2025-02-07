classdef Timestamp < mag.process.Step
% TIMESTAMP Adjust timestamp of data points based on frequency of data.

    methods

        function data = apply(this, data, metaData)
            data.t = this.computeTimeStamp(data{:, ["coarse", "fine"]}, data.sequence, metaData.DataFrequency, metaData.PacketFrequency);
        end
    end

    methods (Hidden)

        function time = computeTimeStamp(this, coarseAndFineTime, sequence, dataFrequency, packetFrequency)

            arguments (Input)
                this
                coarseAndFineTime (:, 2) double
                sequence (:, 1) double
                dataFrequency (1, 1) double
                packetFrequency (1, 1) double
            end

            arguments (Output)
                time (:, 1) double %{mustBeIncreasing}
            end

            % Remove discontinuities in sequence number.
            sequence = this.correctSequence(sequence);
            vectorsPerPacket = dataFrequency * packetFrequency;

            [uniqueSequence, idxSequence] = unique(sequence);
            if any(diff(idxSequence) ~= vectorsPerPacket)

                corruptPackets = uniqueSequence(diff(idxSequence) ~= vectorsPerPacket);
                error("The following packets do not contain %d elements:\n    %s", vectorsPerPacket, join(compose("%d, ", corruptPackets)));
            end

            % Determine time offset to add.
            timeOffset = linspace(0, packetFrequency, vectorsPerPacket + 1);
            timeOffset = timeOffset(1:end-1)';

            numPackets = sequence(end) - sequence(1) + 1;
            timeOffset = repmat(timeOffset, [numPackets, 1]);

            % If last packet was interrupted, crop time offset.
            sizeDifference = numel(timeOffset) - size(coarseAndFineTime, 1);
            assert(sizeDifference >= 0, "Size difference must be greater or equal to zero.");

            if sizeDifference ~= 0
                timeOffset(end-(sizeDifference-1):end) = [];
            end

            % Add time offset to all timestamps.
            timeStamp = coarseAndFineTime(:, 1) + (coarseAndFineTime(:, 2) / double(intmax("uint16")));
            time = timeStamp + timeOffset;
        end
    end
end

function mustBeIncreasing(value)

    if ~all(diff(value) > 0)
        error("Value should be increasing.");
    end
end
