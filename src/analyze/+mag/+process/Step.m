classdef (Abstract) Step < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% STEP Abstract class to capture a processing step for MAG science data.

    methods (Abstract)

        % APPLY Apply processing step.
        data = apply(this, data, metaData)
    end

    methods (Static, Access = protected)

        function sequence = correctSequence(sequence)
        % CORRECTSEQUENCE Find where sequence number restarts, and remove
        % discountinuity.

            deltaSequence = diff(sequence);
            idxSequenceReset = find(deltaSequence < 0);

            for i = idxSequenceReset'
                sequence(i+1:end) = 1 + (sequence(i) - sequence(i + 1)) + sequence(i+1:end);
            end
        end
    end
end
