classdef SID15 < mag.health.Check
% SID15 Check IMAP SID15 HK.

%#ok<*AGROW>

    properties (Constant, Access = private)
        FailedActivationLimit (1, 1) double = 14
        BorderlineActivationLimit (1, 1) double = 10
    end

    methods

        function supported = isSupported(~, results)

            arguments
                ~
                results (1, 1) mag.imap.Instrument
            end

            if ~results.HasHK

                supported = false;
                return;
            end

            sid15 = results.HK.getHKType("SID15");
            supported = ~isempty(sid15) && sid15.HasData;
        end

        function run(this, results)

            arguments
                this (1, 1) mag.imap.health.SID15
                results (1, 1) mag.imap.Instrument
            end

            sid15 = results.HK.getHKType("SID15");
            this.checkActivations(sid15);
        end
    end

    methods (Access = private)

        function checkActivations(this, sid15)

            results = mag.health.Result.empty();

            for attempts = ["FOBAttempts", "FIBAttempts"]

                value = sid15.(attempts);
                sensor = extract(attempts, regexpPattern("F(O|I)B"));

                if any(value >= this.FailedActivationLimit)
                    results(end + 1) = mag.health.Result(Name = compose("%s Activation", sensor), Status = "Fail", Description = compose("%s failed to activate 14 or more times.", sensor));
                elseif any(value >= this.BorderlineActivationLimit)
                    results(end + 1) = mag.health.Result(Name = compose("%s Activation", sensor), Status = "Borderline", Description = compose("%s failed to activate 10 or more times.", sensor));
                end
            end

            if isempty(results)
                results = mag.health.Result(Name = "Sensor Activation", Status = "Pass", Description = "Sensors activated nominally.");
            end

            this.Results = [this.Results, results];
        end
    end
end
