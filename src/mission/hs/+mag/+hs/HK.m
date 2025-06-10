classdef HK < mag.HK
% HK Class containing HelioSwarm MAG HK packet data.

    properties (Dependent)
        % P1V5V +1.5 V voltage.
        P1V5V (:, 1) double
        % P2V5V +2.5 V voltage.
        P2V5V (:, 1) double
        % P8V5V +8.0 V voltage.
        P8V5V (:, 1) double
        % P8V5I +8.0 V current.
        P8V5I (:, 1) double
        % N8V5V -8.5 V voltage.
        N8V5V (:, 1) double
        % N8V5I -8.5 V current.
        N8V5I (:, 1) double
        % BOARDTEMPERATURE Board temperature.
        BoardTemperature (:, 1) double
        % SENSORTEMPERATURE Sensor temperature.
        SensorTemperature (:, 1) double
    end

    methods

        function p1v5v = get.P1V5V(this)
            p1v5v = this.Data.ana_1p5_vlt;
        end

        function p2v5v = get.P2V5V(this)
            p2v5v = this.Data.ana_2p5_vlt;
        end

        function p8v5v = get.P8V5V(this)
            p8v5v = this.Data.ana_p8p5_vlt;
        end

        function p8v5vi = get.P8V5I(this)
            p8v5vi = this.Data.ana_p8p5_cur;
        end

        function n8v5v = get.N8V5V(this)
            n8v5v = this.Data.ana_n8p5_vlt;
        end

        function n8v5v = get.N8V5I(this)
            n8v5v = this.Data.ana_n8p5_cur;
        end

        function boardTemperature = get.BoardTemperature(this)
            boardTemperature = this.Data.ana_brd_tmp;
        end

        function sensorTemperature = get.SensorTemperature(this)
            sensorTemperature = this.Data.ana_sns_tmp;
        end
    end
end
