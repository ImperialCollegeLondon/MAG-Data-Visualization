classdef Science < mag.HK
% SCIENCE Class containing MAG science HK packet data.

    properties (Dependent)
        % FOBT FOB timestamp.
        FOBT (:, 1) datetime
        % FOBX x-axis component of the magnetic field for FOB.
        FOBX (:, 1) double
        % FOBY y-axis component of the magnetic field for FOB.
        FOBY (:, 1) double
        % FOBZ z-axis component of the magnetic field for FOB.
        FOBZ (:, 1) double
        % FOBB Magnitude of the magnetic field for FOB.
        FOBB (:, 1) double
        % FOBRANGE Range values of FOB sensor.
        FOBRange (:, 1) double
        % FIBT FIB timestamp.
        FIBT (:, 1) datetime
        % FIBX x-axis component of the magnetic field for FIB.
        FIBX (:, 1) double
        % FIBY y-axis component of the magnetic field for FIB.
        FIBY (:, 1) double
        % FIBZ z-axis component of the magnetic field for FIB.
        FIBZ (:, 1) double
        % FIBB Magnitude of the magnetic field for FIB.
        FIBB (:, 1) double
        % FIBRANGE Range values of FIB sensor.
        FIBRange (:, 1) double
    end

    methods

        function t = get.FOBT(this)
            t = this.Data.FOB_t;
        end

        function x = get.FOBX(this)
            x = double(this.Data.FOB_XVEC);
        end

        function y = get.FOBY(this)
            y = double(this.Data.FOB_YVEC);
        end

        function z = get.FOBZ(this)
            z = double(this.Data.FOB_ZVEC);
        end

        function b = get.FOBB(this)
            b = vecnorm(this.Data{:, ["FOB_XVEC", "FOB_YVEC", "FOB_ZVEC"]}, 2, 2);
        end

        function range = get.FOBRange(this)
            range = double(this.Data.FOB_RNG);
        end

        function t = get.FIBT(this)
            t = this.Data.FIB_t;
        end

        function x = get.FIBX(this)
            x = double(this.Data.FIB_XVEC);
        end

        function y = get.FIBY(this)
            y = double(this.Data.FIB_YVEC);
        end

        function z = get.FIBZ(this)
            z = double(this.Data.FIB_ZVEC);
        end

        function b = get.FIBB(this)
            b = vecnorm(this.Data{:, ["FIB_XVEC", "FIB_YVEC", "FIB_ZVEC"]}, 2, 2);
        end

        function range = get.FIBRange(this)
            range = double(this.Data.FIB_RNG);
        end
    end
end
