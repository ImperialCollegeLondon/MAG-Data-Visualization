classdef Sensor < uint8
% SENSOR Enumeration for sensor type.

    enumeration
        % OBS Outboard sensor.
        OBS (0)
        % IBS Inboard sensor.
        IBS (1)
    end

    enumeration (Hidden)
        % FOB Outboard sensor (backwards compatibility).
        FOB (0)
        % FIB Inboard sensor (backwards compatibility).
        FIB (1)
    end
end
