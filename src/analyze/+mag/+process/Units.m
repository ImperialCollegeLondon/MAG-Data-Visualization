classdef Units < mag.process.Step
% UNITS Convert from engineering units.

    properties (Constant, Access = private)
        % SCALEFACTORS Scale factors for engineering unit conversions.
        ScaleFactors (1, 1) dictionary = dictionary( ...
            P1V5V = 0.00080322, ...
            P1V8V = 0.00080322, ...
            P3V3V = 0.001164028, ...
            P2V5V = 0.00080322, ...
            P8V = 0.002576341, ...
            N8V = -0.002591041, ...
            P2V4V = 0.001164028, ...
            P1V5I = 0.238840321, ...
            P1V8I = 0.079550361, ...
            P3V3I = 0.07964502, ...
            P2V5I = 0.052732405, ...
            P8VI = 0.1193, ...
            N8VI = 0.1178, ...
            ICU_TEMP = 0.1235727)
        % OFFSETS Offsets for engineering unit conversions.
        Offsets (1, 1) dictionary = dictionary( ...
            P1V5V = 0, ...
            P1V8V = 0, ...
            P3V3V = 0, ...
            P2V5V = 0, ...
            P8V = 0, ...
            N8V = 0, ...
            P2V4V = 0, ...
            P1V5I = -2.0944, ...
            P1V8I = -9.8839, ...
            P3V3I = -13.655, ...
            P2V5I = -9.8261, ...
            P8VI = -9.5705, ...
            N8VI = -8.3906, ...
            ICU_TEMP = -273.15)
    end

    methods

        function data = apply(this, data, metadata)

            arguments
                this
                data tabular
                metadata (1, 1) mag.meta.HK
            end

            switch metadata.Type
                case "PW"
                    data = this.convertPowerEngineeringUnits(data, metadata);
                case "SCI"

                    for fee = ["FOB", "FIB"]

                        steps = [mag.process.AllZero(Variables = fee + ["_COARSETM", "_FINETM", "_XVEC", "_YVEC", "_ZVEC"]), ...
                            mag.process.SignedInteger(IgnoreCompressedData = false, CompressionVariable = "COMPRESSION", ReferenceWidth = 16, ...
                                Variables = fee + ["_XVEC", "_YVEC", "_ZVEC"], AssumedType = "uint16"), ...
                            mag.process.Range(RangeVariable = fee + "_RNG", Variables = fee + ["_XVEC", "_YVEC", "_ZVEC"]), ...
                            mag.process.Calibration(RangeVariable = fee + "_RNG", Variables = fee + ["_XVEC", "_YVEC", "_ZVEC"])];

                        if fee == "FOB"
                            ssu = metadata.OutboardSetup;
                        else
                            ssu = metadata.InboardSetup;
                        end

                        md = mag.meta.Science(Setup = ssu);

                        for s = steps
                            data = s.apply(data, md);
                        end
                    end

                case "SID15"

                    data = this.convertPowerEngineeringUnits(data, metadata);

                    for drt = ["ISV_FOB_DTRDYTM", "ISV_FIB_DTRDYTM"]
                        data{:, drt} = this.convertDataReadyTime(data{:, drt});
                    end

                case {"PROCSTAT", "STATUS"}
                    % nothing to do
                otherwise
                    error("Unrecognized HK type ""%s"".", metadata.Type);
            end
        end
    end

    methods (Access = private)

        function data = convertPowerEngineeringUnits(this, data, metadata)
        % CONVERTPOWERENGINEERINGUNITS Convert power data from engineering
        % units to scientific units.

            % Convert currents and voltages.
            variableNames = string(data.Properties.VariableNames);

            for k = keys(this.ScaleFactors)'

                vn = variableNames(matches(variableNames, regexpPattern(k)));
                data{:, vn} = (data{:, vn} * this.ScaleFactors(k)) + this.Offsets(k);
            end

            % Temperature calibration based on FEE.
            if isempty(metadata.OutboardSetup.FEE)
                fobFEE = "FEE3";
            else
                fobFEE = metadata.OutboardSetup.FEE;
            end

            if isempty(metadata.InboardSetup.FEE)
                fibFEE = "FEE4";
            else
                fibFEE = metadata.InboardSetup.FEE;
            end

            % Convert FOB temperature.
            fobFit = this.getTemperatureFit(fobFEE);
            locFOB = regexpPattern("(ISV_)?FOB_TEMP");

            data{:, locFOB} = fobFit(data{:, locFOB});

            % Convert FIB temperature.
            fibFit = this.getTemperatureFit(fibFEE);
            locFIB = regexpPattern("(ISV_)?FIB_TEMP");

            data{:, locFIB} = fibFit(data{:, locFIB});
        end
    end

    methods (Static, Access = private)

        function f = getTemperatureFit(fee)
        % GETTEMPERATUREFIT Get FEE temperature 3rd degree polynomial fit.

            switch fee
                case "FEE1"
                    x = [1944, 1992, 2037, 2077 ,2134, 2184, 2236, 2252, 2342, 2393, 2447, 2492, 2540, 2606, 2664, 2772, 2821, 2871, 2876, 2928, 2984];
                    y = [-59.1, -54.6, -50, -45.7, -39.9, -34.9, -29.3, -27.5, -18.1, -12.5, -6.6, -1.8, 3.1, 11, 16.9, 30.6, 37.8, 44.3, 45.1, 53.1, 60.9];
                case "FEE2"
                    x = [1944, 1992, 2037, 2079, 2136, 2186, 2240, 2255, 2347, 2400, 2456, 2501, 2552, 2621, 2682, 2785, 2847, 2901, 2908, 2964, 3033];
                    y = [-59.1, -54.8, -50, -45.7, -39.9, -34.6, -29.3, -27.5, -18.4, -12.5, -6.9, -1.8, 4.1, 11.8, 17.2, 30.6, 38.3, 44.3, 45.1, 53.4, 60.9];
                case "FEE3"
                    x = [1950; 1999; 2044; 2085; 2143; 2193; 2247; 2262; 2354; 2407; 2463; 2510; 2560; 2629; 2677; 2692; 2804; 2856; 2910; 2919; 2975; 3034];
                    y = [-59.1; -54.1; -49.5; -45.2; -39.4; -34.4; -28.8; -27; -17.6; -12; -6.1; -1.3; 4.6; 12; 17.7; 18.7; 32.7; 38.9; 45.6; 46.1; 53.9; 62];
                case "FEE4"
                    x = [1949; 1997; 2042; 2083; 2141; 2190; 2243; 2257; 2348; 2400; 2454; 2499; 2548; 2614; 2660; 2675; 2780; 2830; 2879; 2888; 2940; 2994];
                    y = [-59.1; -54.1; -49.5; -45.5; -39.4; -34.4; -28.8; -27; -17.6; -12; -5.9; -1.3; 4.6; 12; 17.4; 18.7; 32.7; 38.9; 45.6; 46.1; 53.9; 62];
            end

            p = polyfit(x, y, 3);
            f = @(x) p(1) * x.^3 + p(2) * x.^2 + p(3) * x + p(4);
        end

        function readyTime = convertDataReadyTime(readyTime)
        % CONVERTDATAREADYTIME Convert data ready time to pseudo-timestamp.

            binRT = dec2bin(readyTime);

            if width(binRT) < 24
                binRT = char(pad(string(binRT), 25, "left", "0"));
            end

            fineTime = bin2dec(binRT(:, end-23:end));
            fineTime = fineTime / (2^24-1);

            coarseTime = bin2dec(binRT(:, 1:end-24));
            readyTime = coarseTime + fineTime;
        end
    end
end
