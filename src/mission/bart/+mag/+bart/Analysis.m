classdef (Sealed) Analysis < mag.Analysis
% ANALYSIS Automate analysis of Bartington data.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("*.Dat")
        % SCIENCEPROCESSING Steps needed to process science data.
        ScienceProcessing (1, :) mag.process.Step = mag.process.Step.empty()
    end

    properties (Dependent)
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
    end

    properties (SetAccess = private)
        % RESULTS Results collected during analysis.
        Results mag.Instrument {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % SCIENCEFILES Information about files containing science data.
        ScienceFiles (:, 1) struct
    end

    methods (Static)

        function analysis = start(options)
        % START Start automated analysis with options.

            arguments
                options.?mag.bart.Analysis
            end

            args = namedargs2cell(options);
            analysis = mag.bart.Analysis(args{:});

            analysis.detect();
            analysis.load();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.bart.Analysis
            end

            this.assignProperties(options);
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function detect(this)
            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
        end

        function load(this)

            this.Results = mag.Instrument();

            this.loadScienceData();
        end

        function export(this, exportType, options)

            arguments
                this (1, 1) mag.bart.Analysis
                exportType (1, 1) string {mustBeMember(exportType, "MAT")}
                options.Location (1, 1) string {mustBeFolder} = "results"
                options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
                options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
            end

            % Determine export classes.
            format = mag.bart.out.("Science" + exportType);

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

                mag.io.export(results, Location = options.Location, Format = format);
            end
        end
    end

    methods (Access = private)

        function loadScienceData(this)

            if isempty(this.ScienceFileNames)
                return;
            end

            this.Results.Science = mag.io.import( ...
                FileNames = this.ScienceFileNames, ...
                Format = mag.bart.in.ScienceDAT(), ...
                ProcessingSteps = this.ScienceProcessing);
        end
    end
end
