classdef (Abstract) Step < matlab.mixin.Copyable & matlab.mixin.Heterogeneous & mag.mixin.SetGet
% STEP Abstract class to capture a processing step for MAG science data.

    methods (Abstract)

        % APPLY Apply processing step.
        data = apply(this, data, metadata)
    end

    methods (Static, Access = protected)

        function sequence = correctSequence(sequence)
        % CORRECTSEQUENCE Find where sequence number restarts, and remove
        % discontinuity.

            % Each reset shifts all later values, so that the sequence
            % continues by one. Shifts add up over resets.
            idxSequenceReset = find(diff(sequence) < 0);

            shift = zeros(size(sequence));
            shift(idxSequenceReset + 1) = 1 + sequence(idxSequenceReset) - sequence(idxSequenceReset + 1);

            sequence = sequence + cumsum(shift);
        end
    end
end
