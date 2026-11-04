classdef Analysis < mag.Analysis
% ANALYSIS Automate analysis of an IMAP data.

    properties
        % EVENTPATTERN Pattern of event files.
        EventPattern string {mustBeScalarOrEmpty} = fullfile("*", "Event", "*.html")
        % METADATAPATTERN Pattern of metadata files.
        MetadataPattern (1, :) string = ["imap_setup.json", "*.msg", "IMAP-MAG-TE-ICL-058*.xlsx", ...
            "IMAP-MAG-TE-ICL-061*.xlsx", "IMAP-MAG-TE-ICL-071*.docx", "IMAP-OPS-TE-ICL-001*.docx", ...
            "IMAP-OPS-TE-ICL-002*.docx"]
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern string {mustBeScalarOrEmpty} = "MAGScience-*-(*)-*.csv"
        % IALIRTPATTERN Pattern of I-ALiRT data files.
        IALiRTPattern string {mustBeScalarOrEmpty} = "MAGScience-IALiRT-*.csv"
        % HKPATTERN Pattern of housekeeping files.
        HKPattern string {mustBeScalarOrEmpty} = fullfile("*", "Export", "*.csv")
    end

    properties (Dependent)
        % EVENTFILENAMES Files containing event data.
        EventFileNames (1, :) string
        % METADATAFILENAMES Files containing metadata.
        MetadataFileNames (1, :) string
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
        % IALIRTFILENAMES Files containing I-ALiRT data.
        IALiRTFileNames (1, :) string
        % HKFILENAMES Files containing HK data.
        HKFileNames (1, :) string
    end

    properties (Access = private)
        % PRIMARYRAMP Primary ramp mode.
        PrimaryRamp mag.Science {mustBeScalarOrEmpty}
        % SECONDARYRAMP Secondary ramp mode.
        SecondaryRamp mag.Science {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % EVENTFILES Information about files containing event data.
        EventFiles (:, 1) struct = struct(folder={}, name={})
        % METADATAFILES Information about files containing metadata.
        MetadataFiles (:, 1) struct = struct(folder={}, name={})
        % SCIENCEFILES Information about files containing science data.
        ScienceFiles (:, 1) struct = struct(folder={}, name={})
        % IALIRTFILES Information about files containing I-ALiRT data.
        IALiRTFiles (:, 1) struct = struct(folder={}, name={})
        % HKFILES Information about files containing HK data.
        HKFiles cell
    end

    methods (Static)

        function analysis = start(analysisOptions, startOptions)

            arguments
                analysisOptions.?mag.imap.Analysis
                analysisOptions.HealthChecks = [mag.imap.health.Power(), mag.imap.health.SID15(), mag.imap.health.Processor()]
                startOptions.Level (1, 1) mag.imap.meta.Level = mag.imap.meta.Level.L1a
            end

            args = namedargs2cell(analysisOptions);
            analysis = mag.imap.Analysis(args{:});

            % Apply processing steps based on the level, unless specified.
            if ~isfield(analysisOptions, "Processing")
                analysis.Processing = mag.imap.Processing.getStepsForLevel(startOptions.Level);
            end

            analysis.detect();
            analysis.load();
            analysis.check();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.imap.Analysis
            end

            this.assignProperties(options);
        end

        function value = get.EventFileNames(this)
            value = this.getFileNames(this.EventFiles);
        end

        function value = get.MetadataFileNames(this)
            value = this.getFileNames(this.MetadataFiles);
        end

        function value = get.ScienceFileNames(this)
            value = this.getFileNames(this.ScienceFiles);
        end

        function value = get.IALiRTFileNames(this)
            value = this.getFileNames(this.IALiRTFiles);
        end

        function value = get.HKFileNames(this)

            value = {};

            for hkp = 1:numel(this.HKFiles)
                value{hkp} = this.getFileNames(this.HKFiles{hkp}); %#ok<AGROW>
            end
        end

        function detect(this)

            if ~isempty(this.EventPattern) && (strlength(this.EventPattern) > 0)
                this.EventFiles = dir(fullfile(this.Location, this.EventPattern));
            end

            if ~isempty(this.MetadataPattern)

                metadataDir = arrayfun(@dir, fullfile(this.Location, this.MetadataPattern), UniformOutput = false);
                this.MetadataFiles = vertcat(metadataDir{:});
            end

            if ~isempty(this.SciencePattern) && (strlength(this.SciencePattern) > 0)
                this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
            end

            if ~isempty(this.IALiRTPattern) && (strlength(this.IALiRTPattern) > 0)
                this.IALiRTFiles = dir(fullfile(this.Location, this.IALiRTPattern));
            end

            % Load HK files and partition them by HK type.
            if ~isempty(this.HKPattern) && (strlength(this.HKPattern) > 0)

                hkFiles = dir(fullfile(this.Location, this.HKPattern));
                this.HKFiles = {};

                for hkType = enumeration(mag.meta.HKType.Power)'
                    this.HKFiles{end + 1} = hkFiles(contains({hkFiles.name}, hkType.ShortName | hkType.PacketName, IgnoreCase = true));
                end
            end
        end

        function load(this)

            this.Results = mag.imap.Instrument();

            this.PrimaryRamp = mag.Science.empty();
            this.SecondaryRamp = mag.Science.empty();

            [primarySetup, secondarySetup] = this.loadMetadata();

            this.loadEventsData();

            this.loadScienceData(primarySetup, secondarySetup);

            this.loadHKData();
        end

        function modes = getAllModes(this)
        % GETALLMODES Get all modes as separate data.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
            end

            arguments (Output)
                modes (1, :) mag.imap.Instrument
            end

            modes = this.Results.getAllModes();
        end

        function modeCycling = getModeCycling(this, options)
        % GETMODECYCLING Get mode cycling data.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
                options.PrimaryPattern (1, :) double
                options.SecondaryPattern (1, :) double
            end

            arguments (Output)
                modeCycling mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            args = namedargs2cell(options);
            modeCycling = this.Results.getModeCycling(args{:});
        end

        function rangeCycling = getRangeCycling(this, options)
        % GETRANGECYCLING Get range cycling data.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
                options.Pattern (1, :) double
            end

            arguments (Output)
                rangeCycling mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            args = namedargs2cell(options);
            rangeCycling = this.Results.getRangeCycling(args{:});
        end

        function rampMode = getRampMode(this)
        % GETRAMPMODE Get ramp mode data.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
            end

            arguments (Output)
                rampMode mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            rampMode = this.Results.copy();
            rampMode.Science = [this.PrimaryRamp, this.SecondaryRamp];

            if rampMode.HasScience
                rampMode.cropToMatch();
            else
                rampMode = mag.imap.Instrument.empty();
            end
        end

        function finalNormal = getFinalNormalMode(this)
        % GETFINALNORMALMODE Get normal mode at the end of analysis.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
            end

            arguments (Output)
                finalNormal mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            finalNormal = this.Results.getFinalNormalMode();
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);
            copiedThis.Results = copy(this.Results);
        end
    end

    methods (Access = private)

        % LOADEVENTSDATA Load events.
        loadEventsData(this)

        % LOADMETADATA Load metadata.
        [primarySetup, secondarySetup] = loadMetadata(this)

        % LOADSCIENCEDATA Load science and I-ALiRT data.
        loadScienceData(this, primarySetup, secondarySetup)

        % LOADHKDATA Load HK data.
        loadHKData(this)

        % GENERATEEVENTTABLE Create an event table for a sensor, based on
        % detected events and science data.
        eventTable = generateEventTable(this, data, sensorEvents)

        function importStrategy = dispatchExtension(this, extension, type)
        % DISPATCHEXTENSION Dispatch extension to correct I/O strategy.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
                extension
                type (1, 1) string {mustBeMember(type, ["Science", "HK"])}
            end

            arguments (Output)
                importStrategy (1, 1) mag.io.in.Format
            end

            switch extension
                case mag.io.in.CSV.Extension

                    format = "CSV";
                    args = {"Metadata", this.Results.Metadata};
                case mag.io.in.CDF.Extension

                    format = "CDF";
                    args = {"CDFSettings", mag.io.CDFSettings(Field = "vectors", Range = "vectors")};
                otherwise
                    error("mag:imap:UnsupportedExtension", "Unsupported extension ""%s"" for science data import.", extension);
            end

            importStrategy = feval("mag.imap.in." + type + format, args{:});
        end
    end

    methods (Static, Access = private)

        function science = addMissingSensor(science)
        % ADDMISSINGSENSOR Add empty data for sensor missing from imported
        % science, so that both primary and secondary sensors exist.

            arguments
                science (1, :) mag.Science
            end

            if ~isscalar(science)
                return;
            end

            metadata = science.Metadata.copy();
            metadata.Primary = ~metadata.Primary;

            if metadata.Sensor == mag.meta.Sensor.OBS
                metadata.Sensor = mag.meta.Sensor.IBS;
            else
                metadata.Sensor = mag.meta.Sensor.OBS;
            end

            science = [science, mag.Science(science.Data([], :), metadata)];
        end

        function idxRamp = findRampEvents(events)
        % FINDRAMPEVENTS Find indices of ramp mode events, followed by
        % indices of the events after them, which end ramp mode. Ramp
        % mode can be the last event, with nothing marking its end.

            arguments (Input)
                events timetable
            end

            arguments (Output)
                idxRamp (:, 1) double
            end

            idxRamp = find(contains([events.Label], "Ramp", IgnoreCase = true));
            idxRamp = vertcat(idxRamp, idxRamp + 1);

            idxRamp(idxRamp > height(events)) = [];
        end
    end

    methods (Hidden, Static)

        % FINDMODECHANGES Improve estimate of mode change times.
        eventData = findModeChanges(data, eventData, name)

        % UPDATERAMPMODETIMESTAMPS Improve estimate of ramp mode times.
        eventData = updateRampModeTimestamps(eventData, data)
    end
end
