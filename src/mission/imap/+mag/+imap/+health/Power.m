classdef Power < mag.imap.health.HKCheck
% POWER Check IMAP power HK.

%#ok<*AGROW>

    properties (Constant)
        % HKTYPE Type of HK checked.
        HKType = "Power"
        % PROPERTYTOHUMANREADABLECONVERSION Human-readable names of HK properties.
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
            FOBTemperature = "OBS Temperature", ...
            FIBTemperature = "IBS Temperature")
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
            P1V8I = {[15, 46]}, ...
            P3V3I = {[110, 147]}, ...
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

            pwr = this.getHK(results);

            % Only check secondary voltages and currents on FM,
            % as the limits are defined for FM only.
            if ~isempty(results.Metadata) && ~isempty(results.Metadata.Model)
                skipSecondaryChecks = results.Metadata.Model ~= "FM";
            else
                skipSecondaryChecks = false;
            end

            if skipSecondaryChecks

                this.Results(end + 1) = mag.health.Result(Name = "Secondary Voltages", Status = "Incomplete", Description = "Secondary voltage limits are only defined for IMAP FM.");
                this.Results(end + 1) = mag.health.Result(Name = "Secondary Currents", Status = "Incomplete", Description = "Secondary current limits are only defined for IMAP FM.");
            else

                this.checkLimits(pwr, "Secondary Voltages", "Secondary voltages within limits.", ...
                    DangerLimits = this.SecondaryVoltagesDangerLimits, WarningLimits = this.SecondaryVoltagesWarningLimits);
                this.checkLimits(pwr, "Secondary Currents", "Secondary currents within limits.", ...
                    WarningLimits = this.SecondaryCurrentsWarningLimits, WarningType = "nominal");
            end

            this.checkLimits(pwr, "Temperatures", "Sensor and ICU temperatures within limits.", ...
                DangerLimits = this.TemperatureDangerLimits, WarningLimits = this.TemperatureWarningLimits);
            this.checkSaturation(pwr);
            this.checkMissedITFFrames(pwr);
        end
    end

    methods (Access = private)

        function checkLimits(this, pwr, name, passDescription, options)
        % CHECKLIMITS Check values against danger limits, if any, and
        % warning limits. Values that exceed a danger limit are not
        % checked against warning limits.

            arguments
                this (1, 1) mag.imap.health.Power
                pwr (1, 1) mag.imap.hk.Power
                name (1, 1) string
                passDescription (1, 1) string
                options.DangerLimits (1, 1) dictionary = dictionary()
                options.WarningLimits (1, 1) dictionary
                options.WarningType (1, 1) string = "warning"
            end

            if numEntries(options.DangerLimits) == 0
                results = mag.health.Result.empty();
                warningValues = keys(options.WarningLimits);
            else

                results = this.checkValueAgainstLimits(pwr, keys(options.DangerLimits), options.DangerLimits, "danger", "Fail");
                warningValues = setdiff(keys(options.WarningLimits), string([results.Name]));
            end

            results = [results, ...
                this.checkValueAgainstLimits(pwr, warningValues, options.WarningLimits, options.WarningType, "Borderline")];

            % Convert names to human-readable format.
            for r = results
                r.Name = this.PropertyToHumanReadableConversion(r.Name);
            end

            % If no failures so far, it's a pass.
            if isempty(results)
                results = mag.health.Result(Name = name, Status = "Pass", Description = passDescription);
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

            if any(pwr.MissedITFs > 0)

                status = mag.health.Status.Fail;
                description = compose("%d missed ITF frames.", max(pwr.MissedITFs));
            else

                status = mag.health.Status.Pass;
                description = "No missed ITF frames.";
            end

            this.Results(end + 1) = mag.health.Result(Name = "Missed ITF Count (POWER)", ...
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
