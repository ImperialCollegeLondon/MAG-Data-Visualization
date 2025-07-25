classdef Spice < mag.process.Step
% SPICE Compute timestamp with SPICE data.

    properties (Constant)
        % SPACECRAFTIDS Mapping of missions to SPICE spacecraft ID.
        SpacecraftIDs (1, 1) dictionary = dictionary(mag.meta.Mission.IMAP, -43)
    end

    properties (SetAccess = private)
        % SPACECRAFTEPOCHS Mapping of missions to SPICE spacecraft epoch.
        SpacecraftEpochs (1, 1) dictionary
    end

    properties
        % FILELOCATION Location of calibration files.
        FileLocation (1, 1) string = fullfile(fileparts(mfilename("fullpath")), "../../spice")
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

            this.assignProperties(options);

            % Initialize SPICE.
            this.initializeSPICE();

            % Value of epochs can only be assigned after SPICE is
            % initialized.
            this.SpacecraftEpochs = dictionary(mag.meta.Mission.IMAP, ...
                datetime(cspice_et2utc(cspice_unitim(0, 'TT', 'ET'), 'ISOC', 9) + "Z", TimeZone = "UTCLeapSeconds"));
        end

        function supported = isSupported(this, mission)

            arguments
                this (1, 1) mag.process.Spice
                mission (1, 1) mag.meta.Mission = this.Mission
            end

            supported = this.SpacecraftIDs.isKey(mission) && this.SpacecraftEpochs.isKey(mission);
        end

        function data = apply(this, data, ~)

            id = this.SpacecraftIDs(this.Mission);
            epoch = this.SpacecraftEpochs(this.Mission);

            met = data.(this.TimeVariable);
            sclk = met / 2e-5;
            secondsSinceJ2000 = cspice_unitim(cspice_sct2e(id, sclk'), 'ET', 'TT')';

            ttJ2000 = epoch + seconds(secondsSinceJ2000);

            % Change time zone from UTCLeapSeconds to UTC.
            ttJ2000.TimeZone = mag.time.Constant.TimeZone;
            ttJ2000.Format = mag.time.Constant.Format;

            data.(this.TimeVariable) = ttJ2000;
        end
    end

    methods (Access = private)

        function initializeSPICE(this)

            persistent spiceInitialized

            if isempty(spiceInitialized) || ~spiceInitialized

                spiceFiles = dir(fullfile(this.FileLocation, "*.t*"));

                for sf = spiceFiles(:)'
                    cspice_furnsh(fullfile(sf.folder, sf.name));
                end

                spiceInitialized = true;
            end
        end
    end
end
