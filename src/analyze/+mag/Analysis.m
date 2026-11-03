classdef (Abstract) Analysis < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.SaveLoad
% ANALYSIS Abstract base class for mission data analysis.

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % PROCESSING Processing steps for each phase.
        Processing (1, 1) mag.Processing
        % HEALTHCHECKS Health checks to perform on results.
        HealthChecks (1, :) mag.health.Check = mag.health.Check.empty()
    end

    properties (SetAccess = protected)
        % RESULTS Results collected during analysis.
        Results mag.Instrument {mustBeScalarOrEmpty}
    end

    methods (Abstract, Static)

        % START Start automated analysis with options.
        analysis = start(options)
    end

    methods (Abstract)

        % DETECT Detect files based on patterns.
        detect(this)

        % LOAD Load all data stored in selected location.
        load(this)

        % EXPORT Export data to specified format.
        export(this, exportType, options)
    end

    methods

        function this = Analysis()

            % Create processing steps for each analysis, as a default value
            % of a handle would be shared by all analyses.
            this.Processing = mag.Processing();
        end

        function check(this)
        % CHECK Check health of results.

            assert(~isempty(this.Results), "Results must be loaded first.");

            if isempty(this.HealthChecks)
                return;
            end

            this.HealthChecks.runAll(this.Results);
            results = [this.HealthChecks.Results];

            if ~isempty(results)
                results.print();
            end
        end
    end

    methods (Access = protected)

        function science = importScience(this, fileNames, format, emptyMetadata)
        % IMPORTSCIENCE Import science data, and apply per-file, whole data
        % and science processing steps. If there is no data and metadata
        % is provided, return empty science data with that metadata.

            arguments
                this (1, 1) mag.Analysis
                fileNames (1, :) string
                format (1, 1) mag.io.in.Format
                emptyMetadata mag.meta.Science {mustBeScalarOrEmpty} = mag.meta.Science.empty()
            end

            if isempty(fileNames)
                science = mag.Science.empty();
            else

                science = mag.io.import( ...
                    FileNames = fileNames, ...
                    Format = format, ...
                    ProcessingSteps = this.Processing.PerFileSteps);

                for step = [this.Processing.WholeDataSteps, this.Processing.ScienceSteps]

                    for s = science
                        s.Data = step.apply(s.Data, s.Metadata);
                    end
                end
            end

            if isempty(science) && ~isempty(emptyMetadata)
                science = mag.Science(timetable(), emptyMetadata);
            end
        end
    end

    methods (Static, Access = protected)

        function fileNames = getFileNames(files)
        % GETFILENAMES Full names of files returned by "dir".

            arguments (Input)
                files (:, 1) struct
            end

            arguments (Output)
                fileNames (1, :) string
            end

            % Before detection, files may be an empty struct with no
            % fields.
            if isempty(files)
                fileNames = string.empty(1, 0);
            else
                fileNames = string(fullfile({files.folder}, {files.name}));
            end
        end

        function cropAndExport(data, period, location, format, fileName)
        % CROPANDEXPORT Crop data to export window, and export any data
        % that is left. Cropping modifies data, so it must not be shared
        % with the analysis.

            arguments
                data (1, :)
                period (1, 1) timerange
                location (1, 1) string
                format (1, 1) mag.io.out.Format
                fileName string {mustBeScalarOrEmpty} = string.empty()
            end

            data.crop(period);

            % Time series, such as HK, have data, and all other types have
            % science.
            if isa(data, "mag.TimeSeries")
                hasData = any([data.HasData]);
            else
                hasData = data.HasScience;
            end

            if hasData
                mag.io.export(data, Location = location, Format = format, FileName = fileName);
            end
        end
    end
end
