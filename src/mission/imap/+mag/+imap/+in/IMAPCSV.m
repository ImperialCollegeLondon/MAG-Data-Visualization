classdef (Abstract) IMAPCSV < mag.io.in.CSV
% IMAPCSV Base class for import of IMAP CSVs.

    properties
        % METADATA Instrument metadata used for processing.
        Metadata mag.meta.Instrument {mustBeScalarOrEmpty} = mag.meta.Instrument.empty()
    end

    properties (Dependent, SetAccess = private)
        % MISSION Mission data belongs to.
        Mission (1, 1) mag.meta.Mission
    end

    methods

        function mission = get.Mission(this)

            if isempty(this.Metadata) || isempty(this.Metadata.Mission)
                mission = mag.meta.Mission.IMAP;
            else
                mission = this.Metadata.Mission;
            end
        end
    end

    methods (Access = protected)

        function step = getTimeConversionStep(this)
            % GETTIMECONVERSIONSTEP Retrieve processing step to convert
            % time information.
            %
            % If SPICE is supported, use SPICE, otherwise, simply convert
            % COARSE and FINE time to MATLAB "datetime".

            spiceStep = mag.process.Spice(Mission = this.Mission);

            if spiceStep.isSupported()
                step = spiceStep;
            else
                step = mag.process.Datetime();
            end
        end
    end
end
