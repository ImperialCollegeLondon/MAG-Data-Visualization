classdef Analysis < mag.Analysis
% ANALYSIS Automate analysis of Vigil data.

    properties
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("*_sci_*.log.txt")
    end

    properties (Dependent)
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
    end

    properties (Access = private)
        % SCIENCEFILES Information about files containing science data.
        ScienceFiles (:, 1) struct
    end

    methods (Static)

        function analysis = start(options)
        % START Start automated analysis with options.

            arguments
                options.?mag.vigil.Analysis
            end

            args = namedargs2cell(options);
            analysis = mag.vigil.Analysis(args{:});

            analysis.detect();
            analysis.load();
            analysis.check();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.vigil.Analysis
            end

            this.Processing.ScienceSteps = [ ...
                mag.process.AllZero(Variables = ["x", "y", "z"]), ...
                mag.process.Sort()];

            this.assignProperties(options);
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function detect(this)
            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
        end

        function load(this)

            metadata = mag.meta.Instrument(Mission = mag.meta.Mission.Vigil);
            this.Results = mag.vigil.Instrument(Metadata = metadata);

            this.loadScienceData();
        end

        function export(this, exportType, options)

            arguments
                this (1, 1) mag.vigil.Analysis
                exportType (1, 1) string {mustBeMember(exportType, "MAT")}
                options.Location (1, 1) string {mustBeFolder} = "results"
                options.StartTime (1, 1) datetime = NaT(TimeZone = "UTC")
                options.EndTime (1, 1) datetime = NaT(TimeZone = "UTC")
            end

            % Determine export classes.
            format = mag.vigil.out.("Science" + exportType);

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

            % Separate FOB and FIB files based on filename prefix.
            fobFiles = this.ScienceFileNames(contains(this.ScienceFileNames, "fob_", IgnoreCase = true));
            fibFiles = this.ScienceFileNames(contains(this.ScienceFileNames, "fib_", IgnoreCase = true));

            fobScience = mag.io.import( ...
                FileNames = fobFiles, ...
                Format = mag.vigil.in.ScienceLOG(Sensor = mag.meta.Sensor.FOB));

            fibScience = mag.io.import( ...
                FileNames = fibFiles, ...
                Format = mag.vigil.in.ScienceLOG(Sensor = mag.meta.Sensor.FIB));

            for sp = this.Processing.ScienceSteps

                for d = [fobScience, fibScience]
                    d.Data = sp.apply(d.Data, d.Metadata);
                end
            end

            if isempty(fobScience)
                fobScience = mag.Science(timetable(), mag.meta.Science(Sensor = mag.meta.Sensor.FOB));
            end

            if isempty(fibScience)
                fibScience = mag.Science(timetable(), mag.meta.Science(Sensor = mag.meta.Sensor.FIB));
            end

            this.Results.Science = [fobScience, fibScience];
        end
    end
end
