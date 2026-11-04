classdef Analysis < mag.Analysis
% ANALYSIS Automate analysis of HelioSwarm data.

    properties
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("science*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, 1) string = fullfile("hk*.csv")
        % DECODEBINARYFILES Decode supported binary files when starting
        % analysis, before detecting CSV files.
        DecodeBinaryFiles (1, 1) logical = true
        % SCALEFACTORS Scale factors used to convert raw science data to nT.
        ScaleFactors (3, 4) double {mustBePositive} = mag.hs.Analysis.getCompleteScaleFactors()
    end

    properties (Dependent)
        % PERFILEPROCESSING Steps needed to process single files of data.
        % Same as "Processing.PerFileSteps".
        PerFileProcessing (1, :) mag.process.Step
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        % Same as "Processing.WholeDataSteps".
        WholeDataProcessing (1, :) mag.process.Step
        % SCIENCEPROCESSING Steps needed to process only strictly science
        % data. Same as "Processing.ScienceSteps".
        ScienceProcessing (1, :) mag.process.Step
        % HKPROCESSING Steps needed to process imported HK data. Same as
        % "Processing.HKSteps".
        HKProcessing (1, :) mag.process.Step
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
        % HKFILENAMES Files containing HK data.
        HKFileNames (1, :) string
    end

    properties (Access = private)
        % SCIENCEFILES Information about files containing science data.
        ScienceFiles (:, 1) struct
        % HKFILES Information about files containing HK data.
        HKFiles (:, 1) struct
    end

    methods (Static)

        function analysis = start(options)
        % START Start automated analysis with options.

            arguments
                options.?mag.hs.Analysis
            end

            args = namedargs2cell(options);
            analysis = mag.hs.Analysis(args{:});

            % Decode binary files into CSV files, before detecting them.
            if analysis.DecodeBinaryFiles
                mag.hs.decodeBinaryFiles(analysis.Location);
            end

            analysis.detect();
            analysis.load();
            analysis.check();
        end

        function scaleFactors = getScaleFactors()
        % GETSCALEFACTORS Return HelioSwarm range scale factors for each axis.

            scaleFactors = [0.007848358, 0.000253372, 6.4682E-05, 1.57585E-05; ...
                            0.007700729, 0.000248428, 6.3446E-05, 1.54839E-05; ...
                            0.007700729, 0.000248428, 6.3446E-05, 1.54839E-05];
        end

        function extraScaling = getExtraScaling()
        % GETEXTRASCALING Return HelioSwarm extra scaling

            extraScaling = 1;
        end

        function completeScaleFactors = getCompleteScaleFactors()
        % GETCOMPLETESCALEFACTORS Return complete factors (ExtraScaling * ScaleFactors).

            completeScaleFactors = mag.hs.Analysis.getExtraScaling() * mag.hs.Analysis.getScaleFactors();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.hs.Analysis
            end

            this.Processing.PerFileSteps = mag.process.AllZero(Variables = ["x", "y", "z"]);

            this.Processing.WholeDataSteps = [ ...
                mag.process.Sort(), ...
                mag.process.Duplicates()];

            this.Processing.ScienceSteps = mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"]);

            this.assignProperties(options);
        end

        function value = get.PerFileProcessing(this)
            value = this.Processing.PerFileSteps;
        end

        function set.PerFileProcessing(this, value)
            this.Processing.PerFileSteps = value;
        end

        function value = get.WholeDataProcessing(this)
            value = this.Processing.WholeDataSteps;
        end

        function set.WholeDataProcessing(this, value)
            this.Processing.WholeDataSteps = value;
        end

        function value = get.ScienceProcessing(this)
            value = this.Processing.ScienceSteps;
        end

        function set.ScienceProcessing(this, value)
            this.Processing.ScienceSteps = value;
        end

        function value = get.HKProcessing(this)
            value = this.Processing.HKSteps;
        end

        function set.HKProcessing(this, value)
            this.Processing.HKSteps = value;
        end

        function value = get.ScienceFileNames(this)
            value = this.getFileNames(this.ScienceFiles);
        end

        function value = get.HKFileNames(this)
            value = this.getFileNames(this.HKFiles);
        end

        function detect(this)

            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
            this.HKFiles = dir(fullfile(this.Location, this.HKPattern));
        end

        function load(this)

            this.Results = mag.Instrument();

            this.loadMetadata();
            this.loadScienceData();
            this.loadHKData();
        end

        function export(this, exportType, options)

            arguments
                this (1, 1) mag.hs.Analysis
                exportType (1, 1) string {mustBeMember(exportType, "MAT")}
                options.Location (1, 1) string {mustBeFolder} = "results"
                options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
                options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
            end

            % Determine export classes.
            scienceFormat = mag.hs.out.("Science" + exportType);
            hkFormat = mag.hs.out.("HK" + exportType);

            % Determine export window.
            period = mag.time.closedTimerange(options.StartTime, options.EndTime);

            % Export full science.
            if this.Results.HasScience
                this.cropAndExport(this.Results.copy(), period, options.Location, scienceFormat);
            end

            % Export HK data.
            if this.Results.HasHK
                this.cropAndExport(this.Results.HK.copy(), period, options.Location, hkFormat);
            end
        end
    end

    methods (Access = private)

        function loadMetadata(this)
            this.Results.Metadata = mag.meta.Instrument(Mission = mag.meta.Mission.HelioSwarm);
        end

        function loadScienceData(this)

            if isempty(this.ScienceFileNames)
                return;
            end

            % Customize range scale factors.
            scienceSteps = this.Processing.ScienceSteps.copy();
            rangeLoc = arrayfun(@(x) isa(x, "mag.process.Range"), scienceSteps);

            if any(rangeLoc)

                rangeStep = scienceSteps(rangeLoc);

                rangeStep.ScaleFactors = this.ScaleFactors;
                rangeStep.ExtraScaling = 1;

                this.Processing.ScienceSteps = scienceSteps;
            end

            this.Results.Science = this.importScience(this.ScienceFileNames, mag.hs.in.ScienceCSV());
        end

        function loadHKData(this)

            if isempty(this.HKFileNames)
                return;
            end

            this.Results.HK = mag.io.import( ...
                FileNames = this.HKFileNames, ...
                Format = mag.hs.in.HKCSV(), ...
                ProcessingSteps = this.Processing.HKSteps);
        end
    end
end
