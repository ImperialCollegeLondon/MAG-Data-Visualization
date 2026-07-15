classdef Mission < matlab.mixin.CustomCompactDisplayProvider
% MISSION Enumeration for mission name.

    enumeration
        % BARTINGTON Bartington reference.
        Bartington ("Bartington", "Bart")
        % HENON HENON mission.
        HENON ("HENON", "HENON")
        % HELIOSWARM HelioSwarm mission.
        HelioSwarm ("HelioSwarm", "HS")
        % IMAP IMAP mission.
        IMAP ("IMAP", "IMAP")
        % VIGIL Vigil mission.
        Vigil ("Vigil", "Vigil")
    end

    properties (SetAccess = immutable)
        DisplayName (1, 1) string
        ShortName (1, 1) string
    end

    methods

        function enum = Mission(displayName, shortName)

            enum.DisplayName = displayName;
            enum.ShortName = shortName;
        end
    end

    methods (Hidden)

        function representation = compactRepresentationForSingleLine(this, displayConfiguration, width)
            representation = this.widthConstrainedDataRepresentation(displayConfiguration, width);
        end

        function representation = compactRepresentationForColumn(this, displayConfiguration, ~)
            representation = this.fullDataRepresentation(displayConfiguration);
        end
    end
end
