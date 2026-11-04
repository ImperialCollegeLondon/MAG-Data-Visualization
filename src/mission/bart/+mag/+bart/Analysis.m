classdef Analysis < mag.Analysis
% ANALYSIS Automate analysis of Bartington data.

    properties
        % INPUT1PATTERN Pattern of input 1 data files.
        Input1Pattern (1, 1) string = fullfile("*Input 1*.Dat")
        % INPUT2PATTERN Pattern of input 2 data files.
        Input2Pattern (1, 1) string = fullfile("*Input 2*.Dat")
    end

    properties (Dependent)
        % SCIENCEPROCESSING Steps needed to process science data. Same as
        % "Processing.ScienceSteps".
        ScienceProcessing (1, :) mag.process.Step
        % INPUT1FILENAMES Files containing input 1 data.
        Input1FileNames (1, :) string
        % INPUT2FILENAMES Files containing input 2 data.
        Input2FileNames (1, :) string
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
            analysis.check();
        end
    end

    methods

        function this = Analysis(options)

            arguments
                options.?mag.bart.Analysis
            end

            this.Processing.ScienceSteps = [ ...
                mag.process.AllZero(Variables = ["x", "y", "z"]), ...
                mag.process.Sort()];

            this.assignProperties(options);
        end

        function value = get.ScienceProcessing(this)
            value = this.Processing.ScienceSteps;
        end

        function set.ScienceProcessing(this, value)
            this.Processing.ScienceSteps = value;
        end

        function value = get.Input1FileNames(this)
            value = this.getFileNames(this.Input1Files);
        end

        function value = get.Input2FileNames(this)
            value = this.getFileNames(this.Input2Files);
        end

        function detect(this)

            this.Input1Files = dir(fullfile(this.Location, this.Input1Pattern));
            this.Input2Files = dir(fullfile(this.Location, this.Input2Pattern));
        end

        function load(this)

            metadata = mag.meta.Instrument(Mission = mag.meta.Mission.Bartington);
            this.Results = mag.bart.Instrument(Metadata = metadata);

            this.loadScienceData();
        end

        function export(~, varargin)
            error("mag:bart:NoExportFormats", "No Bartington-specific export formats are currently supported.");
        end
    end

    methods (Access = private)

        function loadScienceData(this)

            if isempty(this.Input1FileNames) && isempty(this.Input2FileNames)
                return;
            end

            input1Science = this.importScience(this.Input1FileNames, mag.bart.in.ScienceDAT(InputType = 1), ...
                mag.meta.Science(Sensor = mag.meta.Sensor.OBS));

            input2Science = this.importScience(this.Input2FileNames, mag.bart.in.ScienceDAT(InputType = 2), ...
                mag.meta.Science(Sensor = mag.meta.Sensor.IBS));

            this.Results.Science = [input1Science, input2Science];
        end
    end
end
