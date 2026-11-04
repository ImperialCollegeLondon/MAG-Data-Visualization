classdef Processor < mag.imap.health.HKCheck
% PROCESSOR Check IMAP processor HK.

%#ok<*AGROW>

    properties (Constant)
        % HKTYPE Type of HK checked.
        HKType = "Processor"
    end

    methods

        function run(this, results)

            arguments
                this (1, 1) mag.imap.health.Processor
                results (1, 1) mag.imap.Instrument
            end

            procStat = this.getHK(results);

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
            lowerState = lower(state);

            if any(procStat.(property) > 0)

                status = mag.health.Status.Fail;
                description = compose("%d %s ITF frames.", max(procStat.(property)), lowerState);
            else

                status = mag.health.Status.Pass;
                description = compose("No %s ITF frames.", lowerState);
            end

            this.Results(end + 1) = mag.health.Result(Name = compose("%s ITF Count (PROCSTAT)", state), ...
                Status = status, Description = description);
        end
    end
end
