classdef (Sealed) Analysis < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.SaveLoad
% ANALYSIS Automate analysis of HelioSwarm data.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % METADATAPATTERN Pattern of meta data files.
        MetaDataPattern (1, 1) string = ""
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, 1) string = fullfile("science*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, 1) string = fullfile("hk*.csv")
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.AllZero(Variables = ["time", "x", "y", "z"])]
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
        % SCIENCEPROCESSING Steps needed to process only strictly science
        % data.
        ScienceProcessing (1, :) mag.process.Step = mag.process.Step.empty()
        % HKPROCESSING Steps needed to process imported HK data.
        HKProcessing (1, :) mag.process.Step = mag.process.Step.empty()
    end

    properties (Dependent)
        % METADATAFILENAMES Files containing meta data.
        MetaDataFileNames (1, :) string
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
        % METADATAFILES Information about files containing meta data.
        MetaDataFiles (:, 1) struct
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

        function value = get.MetaDataFileNames(this)
            value = string(fullfile({this.MetaDataFiles.folder}, {this.MetaDataFiles.name}));
        end

        function value = get.ScienceFileNames(this)
            value = string(fullfile({this.ScienceFiles.folder}, {this.ScienceFiles.name}));
        end

        function value = get.HKFileNames(this)

            for hkp = 1:numel(this.HKPattern)
                value{hkp} = string(fullfile({this.HKFiles{hkp}.folder}, {this.HKFiles{hkp}.name})); %#ok<AGROW>
            end
        end

        function detect(this)
        % DETECT Detect files based on patterns.

            % metaDataDir = arrayfun(@dir, fullfile(this.Location, this.MetaDataPattern), UniformOutput = false);
            % this.MetaDataFiles = vertcat(metaDataDir{:});

            this.ScienceFiles = dir(fullfile(this.Location, this.SciencePattern));
            this.HKFiles = dir(fullfile(this.Location, this.HKPattern));
        end

        function load(this)
        % LOAD Load all data stored in selected location.

            this.Results = mag.Instrument();

            this.loadMetaData();
            this.loadScienceData();
            this.loadHKData();
        end
    end

    methods (Access = private)

        function loadMetaData(this)
            this.Results.MetaData = mag.meta.Instrument(Mission = mag.meta.Mission.HelioSwarm);
        end

        function loadScienceData(this)

            this.Results.Science = mag.io.import( ...
                FileNames = this.ScienceFileNames, ...
                Format = mag.hs.in.ScienceCSV(), ...
                ProcessingSteps = this.PerFileProcessing);
        end

        function loadHKData(~)
            % nothing to do
        end
    end
end
