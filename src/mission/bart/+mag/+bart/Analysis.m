classdef (Sealed) Analysis < mag.Analysis
% ANALYSIS Automate analysis of Bartington data.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % GRADIOMETER Gradiometer mode.
        Gradiometer (1, 1) logical = false
        % INPUT1PATTERN Pattern of input 1 data files.
        Input1Pattern (1, 1) string = fullfile("*Input 1*.Dat")
        % INPUT2PATTERN Pattern of input 2 data files.
        Input2Pattern (1, 1) string = fullfile("*Input 2*.Dat")
        % SCIENCEPROCESSING Steps needed to process science data.
        ScienceProcessing (1, :) mag.process.Step = [ ...
            mag.process.AllZero(Variables = ["x", "y", "z"]), ...
            mag.process.Sort()]
    end

    properties (Dependent)
        % INPUT1FILENAMES Files containing input 1 data.
        Input1FileNames (1, :) string
        % INPUT2FILENAMES Files containing input 2 data.
        Input2FileNames (1, :) string
    end

    properties (SetAccess = private)
        % RESULTS Results collected during analysis.
        Results mag.bart.Instrument {mustBeScalarOrEmpty}
    end

    properties (Access = private)
        % INPUT1FILES Information about files containing input 1 data.
        Input1Files (:, 1) struct
        % INPUT2FILES Information about files containing input 2 data.
        Input2Files (:, 1) struct
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

        function value = get.Input1FileNames(this)
            value = string(fullfile({this.Input1Files.folder}, {this.Input1Files.name}));
        end

        function value = get.Input2FileNames(this)
            value = string(fullfile({this.Input2Files.folder}, {this.Input2Files.name}));
        end

        function detect(this)

            this.Input1Files = dir(fullfile(this.Location, this.Input1Pattern));
            this.Input2Files = dir(fullfile(this.Location, this.Input2Pattern));
        end

        function load(this)

            this.Results = mag.bart.Instrument();

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

            if isempty(this.Input1FileNames) && isempty(this.Input2FileNames)
                return;
            end

            input1Science = mag.io.import( ...
                FileNames = this.Input1FileNames, ...
                Format = mag.bart.in.ScienceDAT(InputType = 1));

            input2Science = mag.io.import( ...
                FileNames = this.Input2FileNames, ...
                Format = mag.bart.in.ScienceDAT(InputType = 2));

            for sp = this.ScienceProcessing

                for d = [input1Science, input2Science]
                    d.Data = sp.apply(d.Data, d.MetaData);
                end
            end

            this.Results.Science = [input1Science, input2Science];
        end
    end
end
