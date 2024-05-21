classdef Constant
% CONSTANT Time constants for MAG instrument.

    properties (Constant)
        % EPOCH Time offset to account for POSIX time starting on 1st Jan
        % 1970.
        Epoch (1, 1) double = 1262304000
        % FORMAT Time format.
        Format (1, 1) string = "dd-MMM-yyyy HH:mm:ss.SSSS"
        % TIMEZONE Time zone of input data.
        TimeZone (1, 1) string = "UTC"
        % EPS Small time difference.
        Eps (1, 1) duration = 1e6 * seconds(eps())
    end
end
