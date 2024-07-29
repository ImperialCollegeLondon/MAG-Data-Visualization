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
        % MODE MAG mode.
        Mode (1, 1) mag.meta.Mode
        % NORMALPRIMARYRATE Normal mode primary sensor rate.
        NormalPrimaryRate (1, 1) double
        % NORMALSECONDARYRATE Normal mode secondary sensor rate.
        NormalSecondaryRate (1, 1) double
        % BURSTPRIMARYRATE Burst mode primary sensor rate.
        BurstPrimaryRate (1, 1) double
        % BURSTSECONDARYRATE Burst mode secondary sensor rate.
        BurstSecondaryRate (1, 1) double
        % ACTIVEPRIMARYRATE Active mode primary sensor rate.
        ActivePrimaryRate (1, 1) double
        % ACTIVESECONDARYRATE Active mode secondary sensor rate.
        ActiveSecondaryRate (1, 1) double
        % COMPRESSION Compression flag.
        Compression (1, 1) logical
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

        function mode = get.Mode(this)
            mode = mag.meta.Mode(this.Data.MAGMODE);
        end

        function rate = get.NormalPrimaryRate(this)
            rate = double(this.Data.NPRI_OUTRATE);
        end

        function rate = get.NormalSecondaryRate(this)
            rate = double(this.Data.NSEC_OUTRATE);
        end

        function rate = get.BurstPrimaryRate(this)
            rate = double(this.Data.BPRI_OUTRATE);
        end

        function rate = get.BurstSecondaryRate(this)
            rate = double(this.Data.BSEC_OUTRATE);
        end

        function rate = get.ActivePrimaryRate(this)
            rate = arrayfun(@(i) this.determineRate(this.Mode(i), this.NormalPrimaryRate(i), this.BurstPrimaryRate(i)), 1:numel(this.Mode))';
        end

        function rate = get.ActiveSecondaryRate(this)
            rate = arrayfun(@(i) this.determineRate(this.Mode(i), this.NormalSecondaryRate(i), this.BurstSecondaryRate(i)), 1:numel(this.Mode))';
        end

        function compression = get.Compression(this)
            compression = double(this.Data.COMPRESSION);
        end
    end

    methods (Static, Access = private)

        function rate = determineRate(mode, normalRate, burstRate)

            switch mode
                case mag.meta.Mode.Normal
                    rate = normalRate;
                case mag.meta.Mode.Burst
                    rate = burstRate;
                otherwise
                    rate = 0;
            end
        end
    end
end
