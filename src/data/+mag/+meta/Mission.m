classdef Mission < matlab.mixin.CustomCompactDisplayProvider
% MISSION Enumeration for mission name.

    enumeration
        % BARTINGTON Bartington reference.
        Bartington ("Bartington", "Bart", "bart")
        % HENON HENON mission.
        HENON ("HENON", "HENON", "henon")
        % HELIOSWARM HelioSwarm mission.
        HelioSwarm ("HelioSwarm", "HS", "hs")
        % IMAP IMAP mission.
        IMAP ("IMAP", "IMAP", "imap")
        % VIGIL Vigil mission.
        Vigil ("Vigil", "Vigil", "vigil")
    end

    properties (SetAccess = immutable)
        % DISPLAYNAME Name to display.
        DisplayName (1, 1) string
        % SHORTNAME Short name.
        ShortName (1, 1) string
        % PACKAGENAME Name of mission namespace, such as "imap" for
        % "mag.imap" and "mag.app.imap".
        PackageName (1, 1) string
    end

    methods

        function enum = Mission(displayName, shortName, packageName)

            enum.DisplayName = displayName;
            enum.ShortName = shortName;
            enum.PackageName = packageName;
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
