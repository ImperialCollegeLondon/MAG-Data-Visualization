classdef ModeChange < mag.event.Event
% MODECHANGE Description of a mode change event.

    properties (Constant)
        SpecificFormat = ", NORMPRI_RATE=(?<primaryNormal>HZ_\d+|\w+), NORMSEC_RATE=(?<secondaryNormal>HZ_\d+|\w+), NORM_PKTSECS=(?<packetsNormal>SECS_\d+|\w+), BRSTPRI_RATE=(?<primaryBurst>HZ_\d+|\w+), BRSTSEC_RATE=(?<secondaryBurst>HZ_\d+|\w+), BRST_PKTSECS=(?<packetsBurst>SECS_\d+|\w+)"
    end

    properties
        % MODE Mode being changed to.
        Mode (1, 1) mag.meta.Mode = "Normal"
        % PRIMARYNORMALRATE Normal mode rate of primary sensor.
        PrimaryNormalRate (1, 1) double {mustBeMemberOrMissing(PrimaryNormalRate, [1, 2, 4])} = 2
        % SECONDARYNORMALRATE Normal mode rate of secondary sensor.
        SecondaryNormalRate (1, 1) double {mustBeMemberOrMissing(SecondaryNormalRate, [1, 2, 4])} = 2
        % PRIMARYBURSTRATE Burst mode rate of primary sensor.
        PrimaryBurstRate (1, 1) double {mustBeMemberOrMissing(PrimaryBurstRate, [8, 64, 128])} = 64
        % SECONDARYBURSTRATE Burst mode rate of secondary sensor.
        SecondaryBurstRate (1, 1) double {mustBeMemberOrMissing(SecondaryBurstRate, [8, 64, 128])} = 8
        % NORMALPACKETFREQUENCY Frequency of data packets in Normal mode.
        PacketNormalFrequency (1, 1) double {mustBeMemberOrMissing(PacketNormalFrequency, [2, 4, 8])} = 8
        % BURSTPACKETFREQUENCY Frequency of data packets in Burst mode.
        PacketBurstFrequency (1, 1) double {mustBeMemberOrMissing(PacketBurstFrequency, [2, 4, 8])} = 4
        % DURATION Duration of burst mode.
        Duration (1, 1) double = 0
    end

    properties (Dependent)
        % ACTIVEPRIMARYRATE Rate of primary sensor in active mode.
        ActivePrimaryRate (1, 1) double
        % ACTIVESECONDARYRATE Rate of secondary sensor in active mode.
        ActiveSecondaryRate (1, 1) double
        % ACTIVEPACKETFREQUENCY Frequency of data packets in active mode.
        ActivePacketFrequency (1, 1) double
    end

    methods

        function this = ModeChange(options)

            arguments
                options.?mag.event.ModeChange
            end

            this.assignProperties(options);
        end

        function activePrimaryRate = get.ActivePrimaryRate(this)

            switch this.Mode
                case "Normal"
                    activePrimaryRate = this.PrimaryNormalRate;
                case "Burst"
                    activePrimaryRate = this.PrimaryBurstRate;
                otherwise
                    activePrimaryRate = NaN;
            end
        end

        function activeSecondaryRate = get.ActiveSecondaryRate(this)

            switch this.Mode
                case "Normal"
                    activeSecondaryRate = this.SecondaryNormalRate;
                case "Burst"
                    activeSecondaryRate = this.SecondaryBurstRate;
                otherwise
                    activeSecondaryRate = NaN;
            end
        end

        function activePacketFrequency = get.ActivePacketFrequency(this)

            switch this.Mode
                case "Normal"
                    activePacketFrequency = this.PacketNormalFrequency;
                case "Burst"
                    activePacketFrequency = this.PacketBurstFrequency;
                otherwise
                    activePacketFrequency = NaN;
            end
        end
    end

    methods (Access = protected)

        function tableThis = convertToTimeTable(this)

            labels = compose("%s (%d, %d)", string([this.Mode]'), [this.ActivePrimaryRate]', [this.ActiveSecondaryRate]');

            tableThis = timetable(string([this.Mode]), [this.PrimaryNormalRate], [this.SecondaryNormalRate], [this.PacketNormalFrequency], [this.PrimaryBurstRate], [this.SecondaryBurstRate], [this.PacketBurstFrequency], [this.Duration], labels, ...
                RowTimes = this.getTimestamps(), VariableNames = ["Mode", "PrimaryNormalRate", "SecondaryNormalRate", "PacketNormalFrequency", "PrimaryBurstRate", "SecondaryBurstRate", "PacketBurstFrequency", "Duration", "Label"]);
        end
    end

    methods (Static)

        function eventDetails = processEventDetails(eventDetails)
        % PROCESSEVENTDETAILS Process event details by removing extra
        % information and converting values to MATLAB types.

            eventDetails = structfun(@(x) replace(x, ["SECS_", "HZ_", "UNCHANGED"], ["", "", "NaN"]), eventDetails, UniformOutput = false);
        end
    end
end

function mustBeMemberOrMissing(value, allowed)

    if ~ismissing(value)
        mustBeMember(value, allowed);
    end
end
