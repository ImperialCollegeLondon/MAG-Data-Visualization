classdef Level
% LEVEL Enumeration for science data level.

    enumeration
        % L0 Level 0 data. Raw binary.
        L0
        % L1a Level 1a data. Decommutated.
        L1a
        % L1b Level 1b data. Processed.
        L1b
        % L1c Level 1c data. Interpolated.
        L1c
        % L1d Level 1d data. Quasi-calibrated.
        L1d
        % L2 Level 2 data. Calibrated.
        L2
    end
end
