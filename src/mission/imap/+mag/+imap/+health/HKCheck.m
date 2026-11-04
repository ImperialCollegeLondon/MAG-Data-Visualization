classdef (Abstract) HKCheck < mag.health.Check
% HKCHECK Abstract base class for checks of one type of IMAP HK.

    properties (Abstract, Constant)
        % HKTYPE Type of HK checked.
        HKType
    end

    methods

        function supported = isSupported(this, results)

            arguments
                this (1, 1) mag.imap.health.HKCheck
                results (1, 1) mag.imap.Instrument
            end

            if ~results.HasHK

                supported = false;
                return;
            end

            hk = this.getHK(results);
            supported = ~isempty(hk) && hk.HasData;
        end
    end

    methods (Access = protected)

        function hk = getHK(this, results)
        % GETHK Get HK checked from results.

            hk = results.HK.getHKType(this.HKType);
        end
    end
end
