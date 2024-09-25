classdef HK < mag.HK
% HK Class containing MAG HK packet data.

    properties (Dependent)
        % P1V5V +1.5 V voltage.
        P1V5V (:, 1) double
        % P2V5V +2.5 V voltage.
        P2V5V (:, 1) double
        % P2V2I +2.2 V current.
        P2V2I (:, 1) double
        % P12I +12 V current.
        P12I (:, 1) double
        % P8V +8.0 V voltage.
        P8V (:, 1) double
        % P8I +8.0 V current.
        P8VI (:, 1) double
        % TEMPERATURE1 Temperature 1.
        Temperature1 (:, 1) double
        % TEMPERATURE2 Temperature 2.
        Temperature2 (:, 1) double
        % FILTERTYPE Filter type.
        FilterType (:, 1) double
    end

    methods

        function p1v5v = get.P1V5V(this)
            p1v5v = this.Data.p1p5v;
        end

        function p2v5v = get.P2V5V(this)
            p2v5v = this.Data.p2p5v;
        end

        function p2v2i = get.P2V2I(this)
            p2v2i = this.Data.p2p2i;
        end

        function p12i = get.P12I(this)
            p12i = this.Data.p12i;
        end

        function p8v = get.P8V(this)
            p8v = this.Data.p8v;
        end

        function p8vi = get.P8VI(this)
            p8vi = this.Data.p8i;
        end

        function temperature1 = get.Temperature1(this)
            temperature1 = this.Data.temp1;
        end

        function temperature2 = get.Temperature2(this)
            temperature2 = this.Data.temp2;
        end

        function filterType = get.FilterType(this)
            filterType = this.Data.filter_type;
        end
    end
end
