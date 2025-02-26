classdef (Sealed) Analysis < mag.Analysis
% ANALYSIS Automate analysis of HelioSwarm data.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % METADATAPATTERN Pattern of metadata files.
        MetadataPattern string {mustBeScalarOrEmpty} = string.empty()
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("science*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, 1) string = fullfile("hk*.csv")
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.AllZero(Variables = ["x", "y", "z"])]
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
        % SCIENCEPROCESSING Steps needed to process only strictly science
        % data.
        ScienceProcessing (1, :) mag.process.Step = [ ...
            mag.process.Range(RangeVariable = "range", Variables = ["x", "y", "z"], ExtraScaling = 1 / 2^8)]
        % HKPROCESSING Steps needed to process imported HK data.
        HKProcessing (1, :) mag.process.Step = mag.process.Step.empty()
    end

    properties (Dependent)
        % METADATAFILENAMES Files containing metadata.
        MetadataFileNames (1, :) string
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
        % HKFILENAMES Files containing HK data.
        HKFileNames (1, :) string
    end

    properties (SetAccess = private)
        % RESULTS Results collected during analysis.
        Results mag.Instrument {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % METADATAFILES Information about files containing metadata.
        MetadataFiles (:, 1) struct
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

            analysis.detect();
            analysis.load();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.hs.Analysis
            end

            this.assignProperties(options);
        end

        function value = get.MetadataFileNames(this)
            value = string(fullfile({this.MetadataFiles.folder}, {this.MetadataFiles.name}));
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function value = get.HKFileNames(this)
            value = string(fullfile({this.HKFiles.folder}, {this.HKFiles.name}));
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
                exportType (1, 1) string {mustBeMember(exportType, ["MAT", "CDF"])}
                options.Location (1, 1) string {mustBeFolder} = "results"
                options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
                options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
            end

            % Determine export classes.
            scienceFormat = mag.hs.out.("Science" + exportType);
            hkFormat = mag.hs.out.("HK" + exportType);

            % Determine export window.
            if ismissing(options.StartTime)
                options.StartTime = datetime("-Inf", TimeZone = "UTC");
            end

            if ismissing(options.EndTime)
                options.EndTime = datetime("Inf", TimeZone = "UTC");
            end

            period = timerange(options.StartTime, options.EndTime, "closed");

            % Export full science.
            if this.Results.HasScience

                results = this.Results.copy();
                results.crop(period);

                mag.io.export(results, Location = options.Location, Format = scienceFormat);
            end

            % Export HK data.
            if this.Results.HasHK

                hk = this.Results.HK.copy();
                hk.crop(period);

                mag.io.export(hk, Location = options.Location, Format = hkFormat);
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

            science = mag.io.import( ...
                FileNames = this.ScienceFileNames, ...
                Format = mag.hs.in.ScienceCSV(), ...
                ProcessingSteps = this.PerFileProcessing);

            for sp = this.ScienceProcessing

                for s = science
                    s.Data = sp.apply(s.Data, s.Metadata);
                end
            end

            this.Results.Science = science;
        end

        function loadHKData(this)

            if isempty(this.HKFileNames)
                return;
            end

            this.Results.HK = mag.io.import( ...
                FileNames = this.HKFileNames, ...
                Format = mag.hs.in.HKCSV(), ...
                ProcessingSteps = this.HKProcessing);
        end
    end
end
