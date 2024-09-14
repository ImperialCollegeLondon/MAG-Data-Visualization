classdef Power < mag.HK
% POWER Class containing MAG power HK packet data.

    properties (Dependent)
        % ICUTEMPERATURE ICU temperature.
        ICUTemperature (:, 1) double
        % FOBTEMPERATURE FOB temperature.
        FOBTemperature (:, 1) double
        % FIBTEMPERATURE FIB temperature.
        FIBTemperature (:, 1) double
        % P1V5V +1.5 V voltage.
        P1V5V (:, 1) double
        % P1V5I +1.5 V current.
        P1V5I (:, 1) double
        % P1V8V +1.8 V voltage.
        P1V8V (:, 1) double
        % P1V8I +1.8 V current.
        P1V8I (:, 1) double
        % P3V3V +3.3 V voltage.
        P3V3V (:, 1) double
        % P3V3I +3.3 V current.
        P3V3I (:, 1) double
        % P2V5V +2.5 V voltage.
        P2V5V (:, 1) double
        % P2V5I +2.5 V current.
        P2V5I (:, 1) double
        % P8V +8.0 V voltage.
        P8V (:, 1) double
        % P8I +8.0 V current.
        P8VI (:, 1) double
        % N8V -8.0 V voltage.
        N8V (:, 1) double
        % N8I -8.0 V current.
        N8VI (:, 1) double
        % P2V4V +2.4 V voltage.
        P2V4V (:, 1) double
        % MAGORANGE Outboard sensor range.
        MAGoRange (:, 1) double
        % MAGIRANGE Inboard sensor range.
        MAGiRange (:, 1) double
        % MAGOSATFLAGX Outboard sensor x-axis saturation flag.
        MAGoSatFlagX (:, 1) double
        % MAGOSATFLAGY Outboard sensor y-axis saturation flag.
        MAGoSatFlagY (:, 1) double
        % MAGOSATFLAGZ Outboard sensor z-axis saturation flag.
        MAGoSatFlagZ (:, 1) double
        % MAGISATFLAGX Inboard sensor x-axis saturation flag.
        MAGiSatFlagX (:, 1) double
        % MAGISATFLAGY Inboard sensor y-axis saturation flag.
        MAGiSatFlagY (:, 1) double
        % MAGISATFLAGZ Inboard sensor z-axis saturation flag.
        MAGiSatFlagZ (:, 1) double
    end

    methods

        function icuTemperature = get.ICUTemperature(this)
            icuTemperature = this.Data.ICU_TEMP;
        end

        function fobTemperature = get.FOBTemperature(this)
            fobTemperature = this.Data.FOB_TEMP;
        end

        function fibTemperature = get.FIBTemperature(this)
            fibTemperature = this.Data.FIB_TEMP;
        end

        function p1v5v = get.P1V5V(this)
            p1v5v = this.Data.P1V5V;
        end

        function p1v5i = get.P1V5I(this)
            p1v5i = this.Data.P1V5I;
        end

        function p1v8v = get.P1V8V(this)
            p1v8v = this.Data.P1V8V;
        end

        function p1v8i = get.P1V8I(this)
            p1v8i = this.Data.P1V8I;
        end

        function p3v3v = get.P3V3V(this)
            p3v3v = this.Data.P3V3V;
        end

        function p3v3i = get.P3V3I(this)
            p3v3i = this.Data.P3V3I;
        end

        function p2v5v = get.P2V5V(this)
            p2v5v = this.Data.P2V5V;
        end

        function p2v5i = get.P2V5I(this)
            p2v5i = this.Data.P2V5I;
        end

        function p8v = get.P8V(this)
            p8v = this.Data.P8V;
        end

        function p8vi = get.P8VI(this)
            p8vi = this.Data.P8VI;
        end

        function n8v = get.N8V(this)
            n8v = this.Data.N8V;
        end

        function n8vi = get.N8VI(this)
            n8vi = this.Data.N8VI;
        end

        function p2v4v = get.P2V4V(this)
            p2v4v = this.Data.P2V4V;
        end

        function magoRange = get.MAGoRange(this)
            magoRange = this.Data.MAGORANGE;
        end

        function magiRange = get.MAGiRange(this)
            magiRange = this.Data.MAGIRANGE;
        end

        function magoSatFlagX = get.MAGoSatFlagX(this)
            magoSatFlagX = this.Data.MAGOSATFLAGX;
        end

        function magoSatFlagY = get.MAGoSatFlagY(this)
            magoSatFlagY = this.Data.MAGOSATFLAGY;
        end

        function magoSatFlagZ = get.MAGoSatFlagZ(this)
            magoSatFlagZ = this.Data.MAGOSATFLAGZ;
        end

        function magiSatFlagX = get.MAGiSatFlagX(this)
            magiSatFlagX = this.Data.MAGISATFLAGX;
        end

        function magiSatFlagY = get.MAGiSatFlagY(this)
            magiSatFlagY = this.Data.MAGISATFLAGY;
        end

        function magiSatFlagZ = get.MAGiSatFlagZ(this)
            magiSatFlagZ = this.Data.MAGISATFLAGZ;
        end
    end
end
