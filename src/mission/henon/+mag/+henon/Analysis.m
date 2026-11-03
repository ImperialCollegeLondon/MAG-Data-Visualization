classdef Analysis < mag.Analysis
% ANALYSIS Automate analysis of HENON data.

    properties
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("*.*b")
    end

    properties (Dependent)
        % PERFILEPROCESSING Steps needed to process single files of data.
        % Same as "Processing.PerFileSteps".
        PerFileProcessing (1, :) mag.process.Step
        % WHOLEDATAPROCESSING Steps needed to process all imported data.
        % Same as "Processing.WholeDataSteps".
        WholeDataProcessing (1, :) mag.process.Step
        % SCIENCEFILENAMES Files containing science data.
        ScienceFileNames (1, :) string
    end

    properties (Access = private)
        % SCIENCEFILES Information about science files.
        ScienceFiles (:, 1) struct
    end

    methods (Static)

        function analysis = start(options)
        % START Start automated analysis with options.

            arguments
                options.?mag.henon.Analysis
            end

            args = namedargs2cell(options);
            analysis = mag.henon.Analysis(args{:});

            analysis.detect();
            analysis.load();
            analysis.check();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.henon.Analysis
            end

            this.Processing.PerFileSteps = [ ...
                mag.process.AllZero(Variables = ["x", "y", "z"]), ...
                mag.process.Separate(DiscriminationVariable = "timestamps", LargeDiscriminateThreshold = minutes(1), Variables = ["x", "y", "z"])];

            this.Processing.WholeDataSteps = [ ...
                mag.process.Sort(), ...
                mag.process.Duplicates()];

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

        function value = get.ScienceFileNames(this)
            value = this.getFileNames(this.ScienceFiles);
        end

        function detect(this)
            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
        end

        function load(this)

            metadata = mag.meta.Instrument(Mission = mag.meta.Mission.HENON);
            this.Results = mag.henon.Instrument(Metadata = metadata);

            this.loadScienceData();
        end

        function export(~, varargin)
            error("mag:henon:NoExportFormats", "No HENON-specific export formats are currently supported.");
        end
    end

    methods (Access = private)

        function loadScienceData(this)

            if isempty(this.ScienceFileNames)
                return;
            end

            % On HENON, the OBS and IBS file are swapped (".ib" is OBS and
            % ".ob" is IBS).
            obsFiles = this.ScienceFileNames(endsWith(this.ScienceFileNames, ".ib", IgnoreCase = true));
            ibsFiles = this.ScienceFileNames(endsWith(this.ScienceFileNames, ".ob", IgnoreCase = true));

            obsScience = this.importScience(obsFiles, mag.henon.in.ScienceCSV(Sensor = mag.meta.Sensor.OBS), ...
                mag.meta.Science(Primary = true, Sensor = mag.meta.Sensor.OBS));

            ibsScience = this.importScience(ibsFiles, mag.henon.in.ScienceCSV(Sensor = mag.meta.Sensor.IBS), ...
                mag.meta.Science(Primary = false, Sensor = mag.meta.Sensor.IBS));

            this.Results.Science = [obsScience, ibsScience];
        end
    end
end
