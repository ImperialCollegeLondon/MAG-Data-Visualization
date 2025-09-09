classdef Level
% LEVEL Enumeration for science data level.

    enumeration
        % L0 Level 0 data. Raw binary.
        L0 ("Raw binary", "Instrument")
        % L1a Level 1a data. Decommutated.
        L1a ("Decommutated", "GSEOS")
        % L1b Level 1b data. Processed.
        L1b ("Processed", "SDC")
        % L1c Level 1c data. Interpolated.
        L1c ("Interpolated", "SDC")
        % L1d Level 1d data. Quasi-calibrated.
        L1d ("Quasi-calibrated", "SDC")
        % L2 Level 2 data. Calibrated.
        L2 ("Calibrated", "SDC")
    end

    properties
        % DESCRIPTION Description.
        Description (1, 1) string
        % SOURCE Data source.
        Source (1, 1) string
    end

    methods

        function enum = Level(description, source)

            enum.Description = description;
            enum.Source = source;
        end

        function value = string(enum)

            arguments
                enum (:, 1) mag.imap.meta.Level
            end

            value = compose("%s (from %s)", enum, vertcat(enum.Source));
        end
    end
end
