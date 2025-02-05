classdef Spice < mag.process.Step
% SPICE Compute timestamp with SPICE data.

    properties (Constant)
        % FILELOCATION Location of calibration files.
        FileLocation (1, 1) string = fullfile(fileparts(mfilename("fullpath")), "../../spice")
        % SPACECRAFTIDS Mapping of missions to SPICE spacecraft ID.
        SpacecraftIDs (1, 1) dictionary = dictionary(mag.meta.Mission.IMAP, -43)
        % SPACECRAFTEPOCHS Mapping of missions to SPICE spacecraft epoch.
        SpacecraftEpochs (1, 1) dictionary = dictionary(mag.meta.Mission.IMAP, ...
            datetime(cspice_et2utc(cspice_unitim(0, 'TT', 'ET'), 'ISOC', 9) + "Z", TimeZone = "UTCLeapSeconds"))
    end

    properties
        % TIMEVARIABLE Name of time variable.
        TimeVariable (1, 1) string = "t"
        % MISSION Mission to load Spice for.
        Mission (1, 1) mag.meta.Mission
    end

    methods

        function this = Spice(options)

            arguments
                options.?mag.process.Spice
            end

            assert(exist("mice", "file"), "MATLAB SPICE (MICE) Toolbox needs to be installed.");

            spiceFiles = dir(fullfile(this.FileLocation, "*.t*"));

            for sf = spiceFiles(:)'
                cspice_furnsh(fullfile(sf.folder, sf.name));
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            id = this.SpacecraftIDs(this.Mission);
            epoch = this.SpacecraftEpochs(this.Mission);

            met = data.(this.TimeVariable);
            sclk = met / 2e-5;
            ttj2000 = cspice_unitim(cspice_sct2e(id, sclk'), 'ET', 'TT')';

            utc = epoch + seconds(ttj2000);

            % Convert from UTCLeapSeconds to UTC.
            utc.TimeZone = mag.time.Constant.TimeZone;
            utc.Format = mag.time.Constant.Format;

            data.(this.TimeVariable) = utc;
        end
    end
end
