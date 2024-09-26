classdef (Sealed) Analysis < mag.Analysis
% ANALYSIS Automate analysis of an IMAP data.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % EVENTPATTERN Pattern of event files.
        EventPattern (1, :) string = fullfile("*", "Event", "*.html")
        % METADATAPATTERN Pattern of meta data files.
        MetaDataPattern (1, :) string = [fullfile("*.msg"), fullfile("IMAP-MAG-TE-ICL-058*.xlsx"), fullfile("IMAP-MAG-TE-ICL-061*.xlsx"), ...
            fullfile("IMAP-MAG-TE-ICL-071*.docx"), fullfile("IMAP-OPS-TE-ICL-001*.docx"), fullfile("IMAP-OPS-TE-ICL-002*.docx")]
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("MAGScience-*-(*)-*.csv")
        % IALIRTPATTERN Pattern of I-ALiRT data files.
        IALiRTPattern (1, 1) string = fullfile("MAGScience-IALiRT-*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, :) string = [fullfile("*", "Export", "idle_export_conf.*.csv"), ...
            fullfile("*", "Export", "idle_export_proc.*.csv"), ...
            fullfile("*", "Export", "idle_export_pwr.*.csv"), ...
            fullfile("*", "Export", "idle_export_sci.*.csv"), ...
            fullfile("*", "Export", "idle_export_stat.*.csv")]
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.AllZero(Variables = ["coarse", "fine", "x", "y", "z"]), ...
            mag.process.SignedInteger(CompressionVariable = "compression", Variables = ["x", "y", "z"]), ...
            mag.process.Separate(DiscriminationVariable = "t", LargeDiscriminateThreshold = minutes(1), QualityVariable = "quality", Variables = ["x", "y", "z"])]
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
        % SCIENCEPROCESSING Steps needed to process only strictly science
        % data.
        ScienceProcessing (1, :) mag.process.Step = [
            mag.process.Filter(OnModeChange = [0, 1], OnRangeChange = [-1, 5]), ...
            mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
            mag.process.Calibration(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
            mag.process.Compression(CompressionVariable = "compression", CompressionWidthVariable = "compression_width", Variables = ["x", "y", "z"])]
        % IALIRTPROCESSING Steps needed to process only I-ALiRT data.
        IALiRTProcessing (1, :) mag.process.Step = [
            mag.process.Filter(OnRangeChange = [0, 1]), ...
            mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"]), ...
            mag.process.Calibration(RangeVariable = "range", Variables = ["x", "y", "z"])]
        % RAMPPROCESSING Steps needed to process only ramp mode data.
        RampProcessing (1, :) mag.process.Step = [ ...
            mag.process.Unwrap(Variables = ["x", "y", "z"]), ...
            mag.process.Ramp()]
        % HKPROCESSING Steps needed to process imported HK data.
        HKProcessing (1, :) mag.process.Step = [ ...
            mag.process.Units(), ...
            mag.process.Separate(DiscriminationVariable = "t", LargeDiscriminateThreshold = minutes(5), QualityVariable = string.empty(), Variables = "*"), ...
            mag.process.Sort()]
    end

    properties (Dependent)
        % EVENTFILENAMES Files containing event data.
        EventFileNames (1, :) string
        % METADATAFILENAMES Files containing meta data.
        MetaDataFileNames (1, :) string
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
        % IALIRTFILENAMES Files containing I-ALiRT data.
        IALiRTFileNames (1, :) string
        % HKFILENAMES Files containing HK data.
        HKFileNames (1, :) string
    end

    properties (SetAccess = private)
        % RESULTS Results collected during analysis.
        Results mag.imap.Instrument {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % PRIMARYRAMP Primary ramp mode.
        PrimaryRamp mag.Science {mustBeScalarOrEmpty}
        % SECONDARYRAMP Secondary ramp mode.
        SecondaryRamp mag.Science {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % EVENTFILES Information about files containing event data.
        EventFiles (:, 1) struct
        % METADATAFILES Information about files containing meta data.
        MetaDataFiles (:, 1) struct
        % SCIENCEFILES Information about files containing science data.
        ScienceFiles (:, 1) struct
        % IALIRTFILES Information about files containing I-ALiRT data.
        IALiRTFiles (:, 1) struct
        % HKFILES Information about files containing HK data.
        HKFiles cell
    end

    methods (Static)

        function analysis = start(options)

            arguments
                options.?mag.imap.Analysis
            end

            args = namedargs2cell(options);
            analysis = mag.imap.Analysis(args{:});

            analysis.detect();
            analysis.load();
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
            value = string(fullfile({this.EventFiles.folder}, {this.EventFiles.name}));
        end

        function value = get.MetaDataFileNames(this)
            value = string(fullfile({this.MetaDataFiles.folder}, {this.MetaDataFiles.name}));
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function value = get.IALiRTFileNames(this)
            value = string(fullfile({this.IALiRTFiles.folder}, {this.IALiRTFiles.name}));
        end

        function value = get.HKFileNames(this)

            for hkp = 1:numel(this.HKPattern)
                value{hkp} = string(fullfile({this.HKFiles{hkp}.folder}, {this.HKFiles{hkp}.name})); %#ok<AGROW>
            end
        end

        function detect(this)

            this.EventFiles = dir(fullfile(this.Location, this.EventPattern));

            metaDataDir = arrayfun(@dir, fullfile(this.Location, this.MetaDataPattern), UniformOutput = false);
            this.MetaDataFiles = vertcat(metaDataDir{:});

            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));

            this.IALiRTFiles = dir(fullfile(this.Location, this.IALiRTPattern));

            for hkp = 1:numel(this.HKPattern)
                this.HKFiles{hkp} = dir(fullfile(this.Location, this.HKPattern(hkp)));
            end
        end

        function load(this)

            this.Results = mag.imap.Instrument();

            this.loadEventsData();

            [primarySetup, secondarySetup] = this.loadMetaData();

            this.loadScienceData(primarySetup, secondarySetup);

            this.loadIALiRTData(primarySetup, secondarySetup);

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

            function [periods, modeEvents] = findModePeriods(data)

                if isempty(data)

                    periods = {};
                    modeEvents = [];
                    return;
                end

                events = data.Events;

                modeEvents = events(~ismissing(events.Duration), :);
                periods = repmat({timerange()}, 1, height(modeEvents));

                for e = 1:height(modeEvents)

                    if e == height(modeEvents)

                        idxTime = find(modeEvents.Time == modeEvents.Time(e), 1) + 1;

                        if idxTime > height(modeEvents)
                            endTime = data.Time(end);
                        else
                            endTime = modeEvents.Time(idxTime);
                        end
                    else
                        endTime = modeEvents.Time(e + 1);
                    end

                    periods{e} = timerange(modeEvents.Time(e), endTime, "closedleft");
                end
            end

            modes = mag.imap.Instrument.empty();

            % Find duration for each mode.
            [primaryPeriods, primaryEvents] = findModePeriods(this.Results.Primary);
            [secondaryPeriods, secondaryEvents] = findModePeriods(this.Results.Secondary);

            % Split data into separate elements.
            if ~isempty(primaryPeriods) && ~isempty(secondaryPeriods)

                for p = 1:numel(primaryPeriods)

                    data = this.applyTimeRangeToInstrument(primaryPeriods{p}, secondaryPeriods{p});

                    if isempty(data)
                        continue;
                    end

                    data.Primary.MetaData.Mode = string(primaryEvents{p, "Mode"});
                    data.Primary.MetaData.DataFrequency = primaryEvents{p, "DataFrequency"};
                    data.Primary.MetaData.PacketFrequency = primaryEvents{p, "PacketFrequency"};

                    data.Secondary.MetaData.Mode = string(secondaryEvents{p, "Mode"});
                    data.Secondary.MetaData.DataFrequency = secondaryEvents{p, "DataFrequency"};
                    data.Secondary.MetaData.PacketFrequency = secondaryEvents{p, "PacketFrequency"};

                    modes(end + 1) = data; %#ok<AGROW>
                end
            end
        end

        function modeCycling = getModeCycling(this, options)
        % GETMODECYCLING Get mode cycling data.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
                options.PrimaryPattern (1, :) double = [2, 64, 4, 64, 4, 128]
                options.SecondaryPattern (1, :) double = [2, 8, 1, 64, 4, 128]
            end

            arguments (Output)
                modeCycling mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            function period = findModeCyclingPeriod(events, pattern)

                idxMode = strfind(events.DataFrequency', pattern);

                if isempty(idxMode)
                    period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
                else
                    period = timerange(events.Time(idxMode), events.Time(idxMode + numel(pattern)), "closedleft");
                end
            end

            modeCycling = this.applyTimeRangeToInstrument( ...
                findModeCyclingPeriod(this.Results.Primary.Events, options.PrimaryPattern), ...
                findModeCyclingPeriod(this.Results.Secondary.Events, options.SecondaryPattern));
        end

        function rangeCycling = getRangeCycling(this, options)
        % GETRANGECYCLING Get range cycling data.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
                options.Pattern (1, :) double = [3, 2, 1, 0]
            end

            arguments (Output)
                rangeCycling mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            if ~this.Results.HasScience

                rangeCycling = mag.imap.Instrument.empty();
                return;
            end

            function period = findRangeCyclingPeriod(events, pattern)

                idxRange = strfind(events.Range', pattern);

                if isempty(idxRange)
                    period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
                else
                    period = timerange(events.Time(idxRange), events.Time(idxRange + numel(pattern)), "closedleft");
                end
            end

            rangeCycling = this.applyTimeRangeToInstrument( ...
                findRangeCyclingPeriod(this.Results.Primary.Events, options.Pattern), ...
                findRangeCyclingPeriod(this.Results.Secondary.Events, options.Pattern), ...
                EnforceSizeMatch = true);
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

            function period = findFinalNormalMode(events, endTime)

                if any(events{end-2:end, "Mode"} == "Normal")

                    events = events((events.Mode == "Normal") & (events.DataFrequency == 2) & ~contains(events.Label, "Shutdown"), :);
                    period = timerange(events.Time(end), endTime, "closed");
                else
                    period = timerange(NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC"));
                end
            end

            finalNormal = this.applyTimeRangeToInstrument( ...
                findFinalNormalMode(this.Results.Primary.Events, this.Results.Primary.Time(end)), ...
                findFinalNormalMode(this.Results.Secondary.Events, this.Results.Secondary.Time(end)));
        end

        function periods = splitByTimeGap(this, gap)
        % SPLITBYTIMEGAP Split data based on gap in the data of specified
        % magnitude.

            arguments (Input)
                this (1, 1) mag.imap.Analysis
                gap (1, 1) duration
            end

            arguments (Output)
                periods (1, :) mag.imap.Instrument
            end

            tPrimary = this.Results.Primary.Time;
            dtPrimary = diff(tPrimary);
            tSplitPrimary = [tPrimary(1); tPrimary(dtPrimary > gap)];

            tSecondary = this.Results.Secondary.Time;
            dtSecondary = diff(tSecondary);
            tSplitSecondary = [tSecondary(1); tSecondary(dtSecondary > gap)];

            if ~isequal(numel(tSplitPrimary), numel(tSplitSecondary))
                error("Unequal time splits in primary (%d) and secondary(%d) data. Try a different time gap.", numel(tSplitPrimary), numel(tSplitSecondary));
            end

            for i = 1:(numel(tSplitPrimary) - 1)

                periods(i) = this.applyTimeRangeToInstrument(timerange(tSplitPrimary(i), tSplitPrimary(i + 1), "open"), ...
                    timerange(tSplitSecondary(i), tSplitSecondary(i + 1), "open")); %#ok<AGROW>
            end
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

        % LOADMETADATA Load meta data.
        [primarySetup, secondarySetup] = loadMetaData(this)

        % LOADSCIENCEDATA Load science data.
        loadScienceData(this, primarySetup, secondarySetup)

        % LOADIALIRTDATA Load I-ALiRT data.
        loadIALiRTData(this, primarySetup, secondarySetup)

        % LOADHKDATA Load HK data.
        loadHKData(this)

        % GENERATEEVENTTABLE Create an event table for a sensor, based on
        % detected events and science data.
        eventTable = generateEventTable(this, primaryOrSecondary, sensorEvents, data)

        function result = applyTimeRangeToInstrument(this, primaryPeriod, secondaryPeriod, options)
        % APPLYTIMERANGETOTABLE Apply timerange to timetable and its
        % events.

            arguments (Input)
                this
                primaryPeriod (1, 1) timerange
                secondaryPeriod (1, 1) timerange
                options.EnforceSizeMatch (1, 1) logical = false
            end

            arguments (Output)
                result mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            result = this.Results.copy();

            if isempty(result)
                return;
            end

            result.crop(primaryPeriod, secondaryPeriod);

            if ~result.Primary.HasData || ~result.Secondary.HasData
                result = mag.imap.Instrument.empty();
            elseif options.EnforceSizeMatch

                if numel(result.Primary.Time) > numel(result.Secondary.Time)
                    result.Primary.Data = result.Primary.Data(1:numel(result.Secondary.Time), :);
                elseif numel(result.Primary.Time) < numel(result.Secondary.Time)
                    result.Secondary.Data = result.Secondary.Data(1:numel(result.Primary.Time), :);
                end
            end
        end
    end

    methods (Hidden, Sealed, Static)

        function loadedObject = loadobj(object)
        % LOADOBJ Override default loading from MAT file.

            if isa(object, "mag.imap.Analysis")

                loadedObject = object;

                if strlength(object.OriginalVersion) ~= 0
                    return;
                end

                % If no original version is available, make sure the HK
                % data is dispatched to the correct classes.
                results = loadedObject.Results;

                for hk = 1:numel(results.HK)
                    results.HK(hk) = mag.imap.hk.dispatchHKType(results.HK(hk).Data, results.HK(hk).MetaData);
                end
            else

                error("Cannot retrieve ""mag.imap.Analysis"" from ""%s"". Data needs to be reprocessed:" + newline() + newline() + ...
                    ">> mag.imap.Analysis.start(Location = ""%s"")", class(object), object.Location);
            end
        end
    end

    methods (Static, Access = private)

        function importStrategy = dispatchExtension(extension, type)
        % DISPATCHEXTENSION Dispatch extension to correct I/O strategy.

            arguments (Input)
                extension
                type (1, 1) string {mustBeMember(type, ["Science", "HK"])}
            end

            arguments (Output)
                importStrategy (1, 1) mag.io.in.Format
            end

            switch extension
                case mag.io.in.CSV.Extension

                    format = "CSV";
                    args = {};
                case mag.io.in.CDF.Extension

                    format = "CDF";
                    args = {"CDFSettings", mag.io.CDFSettings(Field = "vectors", Range = "vectors")};
                otherwise
                    error("Unsupported extension ""%s"" for science data import.", extension);
            end

            importStrategy = feval("mag.imap.in." + type + format, args{:});
        end
    end
end


