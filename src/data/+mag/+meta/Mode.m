classdef Mode < double
% MODE Enumeration for mode type.

    enumeration
        % STANDBY Standby mode.
        StandBy (1)
        % SAFE Safe mode.
        Safe (2)
        % CONFIG Configuration mode.
        Config (3)
        % DEBUG Debugging mode.
        Debug (4)
        % NORMAL Normal mode.
        Normal (5)
        % BURST Burst mode.
        Burst (6)
        % IALIRT IALiRT mode.
        IALiRT (7)
        % HYBRID Sensor in more than one mode.
        Hybrid (8)
        % NAN Missing value.
        NaN (NaN)
    end
end
