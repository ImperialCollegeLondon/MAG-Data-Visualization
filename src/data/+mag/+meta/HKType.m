classdef HKType
% HKTYPE Enumeration for HK type.

    enumeration
        % POWER Power packet.
        Power ("PW", "hsk-pw", 1063)
        % PROCESSOR Processor stats packet.
        Processor ("PROCSTAT", "hsk-procstat", 1060)
        % SCIENCE Science packet.
        Science ("SCI", "hsk-sci", 1082)
        % SID15 SID15 packet.
        SID15 ("SID15", "hsk-sid15", 1053)
        % STATUS Status packet.
        Status ("STATUS", "hsk-status", 1064)
    end

    properties
        ShortName (1, 1) string
        PacketName (1, 1) string
        ApID (1, 1) double
    end

    methods

        function enum = HKType(shortName, packetName, apID)

            enum.ShortName = shortName;
            enum.PacketName = packetName;
            enum.ApID = apID;
        end

        function sortedEnum = sort(enum)

            [~, idxSort] = sort([enum.ApID]);
            sortedEnum = enum(idxSort);
        end
    end

    methods (Static)

        function enum = fromShortName(shortName)
        % FROMSHORTNAME Retrieve enumeration value from its "ShortName".

            for e = enumeration(mag.meta.HKType.Power)'

                if e.ShortName == shortName

                    enum = e;
                    return;
                end
            end

            error("mag:hk:UnknownShortName", "Unsupported HK short name ""%s"".", shortName);
        end

        function enum = fromPacketName(shortName)
        % FROMPACKETNAME Retrieve enumeration value from its "PacketName".

            for e = enumeration(mag.meta.HKType.Power)'

                if e.PacketName == shortName

                    enum = e;
                    return;
                end
            end

            error("mag:hk:UnknownPacketName", "Unsupported HK packet name ""%s"".", shortName);
        end
    end
end
