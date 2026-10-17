classdef Analysis < mag.Analysis
% ANALYSIS Automate analysis of HENON data.

    properties
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("*.*b")
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.AllZero(Variables = ["x", "y", "z"]), ...
            mag.process.Separate(DiscriminationVariable = "timestamps", LargeDiscriminateThreshold = minutes(1), Variables = ["x", "y", "z"])]
        % WHOLEDATAPROCESSING Steps needed to process all imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
    end

    properties (Dependent)
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

            this.assignProperties(options);
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function detect(this)
            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
        end

        function load(this)

            metadata = mag.meta.Instrument(Mission = mag.meta.Mission.HENON);
            this.Results = mag.henon.Instrument(Metadata = metadata);

            this.loadScienceData();
        end

        function export(~, ~, ~)
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

            obsScience = this.importAndProcess(obsFiles, mag.meta.Sensor.OBS);
            ibsScience = this.importAndProcess(ibsFiles, mag.meta.Sensor.IBS);

            if isempty(obsScience)
                obsScience = mag.Science(timetable(), mag.meta.Science(Primary = true, Sensor = mag.meta.Sensor.OBS));
            end

            if isempty(ibsScience)
                ibsScience = mag.Science(timetable(), mag.meta.Science(Primary = false, Sensor = mag.meta.Sensor.IBS));
            end

            this.Results.Science = [obsScience, ibsScience];
        end

        function science = importAndProcess(this, fileNames, sensor)

            arguments
                this (1, 1) mag.henon.Analysis
                fileNames (1, :) string
                sensor (1, 1) mag.meta.Sensor
            end

            if isempty(fileNames)

                science = mag.Science.empty();
                return;
            end

            science = mag.io.import( ...
                FileNames = fileNames, ...
                Format = mag.henon.in.ScienceCSV(Sensor = sensor), ...
                ProcessingSteps = this.PerFileProcessing);

            for sp = this.WholeDataProcessing

                for s = science
                    s.Data = sp.apply(s.Data, s.Metadata);
                end
            end
        end
    end
end
