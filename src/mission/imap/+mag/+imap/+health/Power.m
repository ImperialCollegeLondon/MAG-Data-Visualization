classdef Power < mag.health.Check
% POWER Check IMAP power HK.

%#ok<*AGROW>

    properties (Constant)
        PropertyToHumanReadableConversion (1, 1) dictionary = dictionary( ...
            P1V5V = "+1.5 V Voltage", ...
            P1V8V = "+1.8 V Voltage", ...
            P3V3V = "+3.3 V Voltage", ...
            P2V5V = "+2.5 V Voltage", ...
            P8V = "+8 V Voltage", ...
            N8V = "-8 V Voltage", ...
            P2V4V = "+2.4 V Voltage", ...
            P1V5I = "+1.5 V Current", ...
            P1V8I = "+1.8 V Current", ...
            P3V3I = "+3.3 V Current", ...
            P2V5I = "+2.5 V Current", ...
            P8VI = "+8 V Current", ...
            N8VI = "-8 V Current", ...
            ICUTemperature = "ICU Temperature", ...
            FOBTemperature = "FOB Temperature", ...
            FIBTemperature = "FIB Temperature")
    end

    properties (Constant, Access = private)
        SecondaryVoltagesDangerLimits (1, 1) dictionary = dictionary( ...
            P1V5V = {[1.42, 1.58]}, ...
            P1V8V = {[1.7, 2]}, ...
            P3V3V = {[3, 3.6]}, ...
            P2V5V = {[2.3, 2.7]}, ...
            P8V = {[8.2, 10.55]}, ...
            N8V = {[-10.61, -8.25]})
        SecondaryVoltagesWarningLimits (1, 1) dictionary = dictionary( ...
            P1V5V = {[1.52, 1.53]}, ...
            P1V8V = {[1.82, 1.84]}, ...
            P3V3V = {[3.35, 3.38]}, ...
            P2V5V = {[2.54, 2.56]}, ...
            P8V = {[9.46, 9.8]}, ...
            N8V = {[-9.8, -9.46]}, ...
            P2V4V = {[2.33, 2.38]})
        SecondaryCurrentsWarningLimits (1, 1) dictionary = dictionary( ...
            P1V5I = {[400, 448]}, ...
            P1V8I = {[15, 43]}, ...
            P3V3I = {[110, 141]}, ...
            P2V5I = {[75, 106]}, ...
            P8VI = {[110, 222]}, ...
            N8VI = {[80, 180]})
        TemperatureDangerLimits (1, 1) dictionary = dictionary( ...
            ICUTemperature = {[-30, 60]}, ...
            FOBTemperature = {[-50, 90]}, ...
            FIBTemperature = {[-50, 90]})
        TemperatureWarningLimits (1, 1) dictionary = dictionary( ...
            ICUTemperature = {[-25, 50]}, ...
            FOBTemperature = {[-45, 59]}, ...
            FIBTemperature = {[-45, 59]})
    end

    methods

        function run(this, results)

            arguments
                this (1, 1) mag.imap.health.Power
                results (1, 1) mag.imap.Instrument
            end

            if ~results.HasHK
                return;
            end

            pwr = results.HK.getHKType("Power");

            if isempty(pwr) || ~pwr.HasData
                return;
            end

            this.checkSecondaryVoltages(pwr);
            this.checkSecondaryCurrents(pwr);
            this.checkTemperatures(pwr);

            this.checkSaturation(pwr);
            this.checkMissedITFFrames(pwr);
        end
    end

    methods (Access = private)

        function checkSecondaryVoltages(this, pwr)

            results = mag.health.Result.empty();

            % Check danger limits.
            results = [results, ...
                this.checkValueAgainstLimits(pwr, keys(this.SecondaryVoltagesDangerLimits), this.SecondaryVoltagesDangerLimits, "danger", "Fail")];

            % Check warning limits.
            warningValues = setdiff(keys(this.SecondaryVoltagesWarningLimits), string([results.Name])); % do not check voltages that failed danger check

            results = [results, ...
                this.checkValueAgainstLimits(pwr, warningValues, this.SecondaryVoltagesWarningLimits, "warning", "Borderline")];

            % Convert voltage names to human-readable format.
            for r = results
                r.Name = this.PropertyToHumanReadableConversion(r.Name);
            end

            % If no failures so far, it's a pass.
            if isempty(results)
                results = mag.health.Result(Name = "Secondary Voltages", Status = "Pass", Description = "Secondary voltages within limits.");
            end

            this.Results = [this.Results, results];
        end

        function checkSecondaryCurrents(this, pwr)

            results = mag.health.Result.empty();

            % Check warning limits.
            results = [results, ...
                this.checkValueAgainstLimits(pwr, keys(this.SecondaryCurrentsWarningLimits), this.SecondaryCurrentsWarningLimits, "nominal", "Borderline")];

            % Convert current names to human-readable format.
            for r = results
                r.Name = this.PropertyToHumanReadableConversion(r.Name);
            end

            % If no failures so far, it's a pass.
            if isempty(results)
                results = mag.health.Result(Name = "Secondary Currents", Status = "Pass", Description = "Secondary currents within limits.");
            end

            this.Results = [this.Results, results];
        end

        function checkTemperatures(this, pwr)

            results = mag.health.Result.empty();

            % Check danger limits.
            results = [results, ...
                this.checkValueAgainstLimits(pwr, keys(this.TemperatureDangerLimits), this.TemperatureDangerLimits, "danger", "Fail")];

            % Check warning limits.
            warningValues = setdiff(keys(this.TemperatureWarningLimits), string([results.Name])); % do not check temperatures that failed danger check

            results = [results, ...
                this.checkValueAgainstLimits(pwr, warningValues, this.TemperatureWarningLimits, "warning", "Borderline")];

            % Convert temperature names to human-readable format.
            for r = results
                r.Name = this.PropertyToHumanReadableConversion(r.Name);
            end

            % If no failures so far, it's a pass.
            if isempty(results)
                results = mag.health.Result(Name = "Temperatures", Status = "Pass", Description = "Sensor and ICU temperatures within limits.");
            end

            this.Results = [this.Results, results];
        end

        function checkSaturation(this, pwr)

            failedAxes = string.empty();

            for flag = ["MAGoSatFlagX", "MAGoSatFlagY", "MAGoSatFlagZ", "MAGiSatFlagX", "MAGiSatFlagY", "MAGiSatFlagZ"]

                if any(pwr.(flag))

                    failedAxes(end + 1) = compose("%s %s-axis", ...
                        extract(flag, regexpPattern("MAG\w")), ...
                        lower(extract(flag, regexpPattern("X|Y|Z"))));
                end
            end

            if isempty(failedAxes)

                status = mag.health.Status.Pass;
                description = "No saturation on any sensor-axis pair.";
            else

                status = mag.health.Status.Fail;
                description = "Saturation on: " + join(failedAxes, ", ");
            end

            this.Results(end + 1) = mag.health.Result(Name = "Saturation Flags", ...
                Status = status, Description = description);
        end

        function checkMissedITFFrames(this, pwr)

            if any(pwr.MissedITF > 0)

                status = mag.health.Status.Fail;
                description = compose("%d missed ITF frames.", max(pwr.MissedITF));
            else

                status = mag.health.Status.Pass;
                description = "No missed ITF frames.";
            end

            this.Results(end + 1) = mag.health.Result(Name = "Missed ITF Count", ...
                Status = status, Description = description);
        end
    end

    methods (Static, Access = private)

        function results = checkValueAgainstLimits(pwr, values, limits, type, status)

            arguments
                pwr (1, 1) mag.imap.hk.Power
                values (1, :) string
                limits (1, 1) dictionary
                type (1, 1) string {mustBeMember(type, ["danger", "warning", "nominal"])}
                status (1, 1) mag.health.Status
            end

            results = mag.health.Result.empty();

            for v = values

                value = pwr.(v);
                limit = limits{v};

                if any(value < limit(1))
                    results(end + 1) = mag.health.Result(Name = v, Status = status, Description = compose("Exceeds %s low limit (%.5g < %.5g).", type, min(value), limit(1)));
                end

                if any(value > limit(2))
                    results(end + 1) = mag.health.Result(Name = v, Status = status, Description = compose("Exceeds %s high limit (%.5g > %.5g).", type, max(value), limit(2)));
                end
            end
        end
    end
end
