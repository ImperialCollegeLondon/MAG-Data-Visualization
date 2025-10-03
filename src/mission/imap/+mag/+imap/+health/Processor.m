classdef Processor < mag.health.Check
% PROCESSOR Check IMAP processor HK.

%#ok<*AGROW>

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

            procStat = results.HK.getHKType("Processor");
            supported = ~isempty(procStat) && procStat.HasData;
        end

        function run(this, results)

            arguments
                this (1, 1) mag.imap.health.Processor
                results (1, 1) mag.imap.Instrument
            end

            procStat = results.HK.getHKType("Processor");

            this.checkSingleBitErrors(procStat);

            this.checkITFFrames(procStat, "Missed");
            this.checkITFFrames(procStat, "Rejected");
        end
    end

    methods (Access = private)

        function checkSingleBitErrors(this, procStat)

            arguments
                this (1, 1) mag.imap.health.Processor
                procStat (1, 1) mag.imap.hk.Processor
            end

            if any(procStat.SingleBitErrors > 0)

                status = mag.health.Status.Fail;
                description = compose("%d single bit errors in SRAM.", max(procStat.SingleBitErrors));
            else

                status = mag.health.Status.Pass;
                description = "No single bit errors in SRAM.";
            end

            this.Results(end + 1) = mag.health.Result(Name = "Single Bit Errors", ...
                Status = status, Description = description);
        end

        function checkITFFrames(this, procStat, state)

            arguments
                this (1, 1) mag.imap.health.Processor
                procStat (1, 1) mag.imap.hk.Processor
                state (1, 1) string {mustBeMember(state, ["Missed", "Rejected"])}
            end

            property = compose("%sITFs", state);
            state = lower(state);

            if any(procStat.(property) > 0)

                status = mag.health.Status.Fail;
                description = compose("%d %s ITF frames.", max(procStat.(property)), state);
            else

                status = mag.health.Status.Pass;
                description = compose("No %s ITF frames.", state);
            end

            this.Results(end + 1) = mag.health.Result(Name = compose("%s ITF Count", state), ...
                Status = status, Description = description);
        end
    end
end
