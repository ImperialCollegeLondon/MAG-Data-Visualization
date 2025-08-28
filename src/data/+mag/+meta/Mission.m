classdef Mission
% MISSION Enumeration for mission name.

    enumeration
        % BARTINGTON Bartington reference.
        Bartington ("Bartington", "Bart")
        % HELIOSWARM HelioSwarm mission.
        HelioSwarm ("HelioSwarm", "HS")
        % IMAP IMAP mission.
        IMAP ("IMAP", "IMAP")
        % SOLARORBITER Solar Orbiter mission.
        SolarOrbiter ("Solar Orbiter", "SO")
    end

    properties
        DisplayName (1, 1) string
        ShortName (1, 1) string
    end

    methods

        function enum = Mission(displayName, shortName)

            enum.DisplayName = displayName;
            enum.ShortName = shortName;
        end
    end
end
