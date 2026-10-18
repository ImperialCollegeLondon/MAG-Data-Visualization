classdef (Abstract) Model < mag.mixin.SetGet
% MODEL Abstract base class for mission analysis models.

    events
        % MODELCHANGED Model changed.
        ModelChanged
    end

    properties (Abstract, Constant, Access = protected)
        % ANALYSISCLASSNAME Name of analysis class.
        AnalysisClassName (1, 1) string
    end

    properties (SetAccess = private)
        % ANALYSIS Analysis results.
        Analysis mag.Analysis {mustBeScalarOrEmpty} = mag.imap.Analysis.empty()
    end

    properties (Dependent, SetAccess = private)
        % HASANALYSIS Logical denoting whether analysis is available.
        HasAnalysis (1, 1) logical
        % TIMERANGE Time range for analysis.
        TimeRange (1, 2) datetime
        % SCIENCETIMERANGE Time range for science data.
        ScienceTimeRange (1, 2) datetime
        % HKTIMERANGE Time range for HK data.
        HKTimeRange (1, 2) datetime
    end

    methods

        function analyze(this, options)
        % ANALYZE Perform analysis.

            arguments
                this (1, 1) mag.app.Model
                options cell
            end

            analysis = feval(this.AnalysisClassName + ".start", options{:});
            this.setAnalysisAndNotify(analysis);
        end

        function task = createAnalysisTask(this, options)
        % CREATEANALYSISTASK Create task to perform analysis in the
        % background. Analysis is updated when task succeeds.

            arguments (Input)
                this (1, 1) mag.app.Model
                options cell
            end

            arguments (Output)
                task (1, 1) mag.app.internal.BackgroundTask
            end

            task = mag.app.internal.BackgroundTask(str2func(this.AnalysisClassName + ".start"), 1, options, ...
                Name = this.AnalysisClassName + ".start", ...
                Description = "Processing data...", ...
                SuccessFcn = @this.setAnalysisAndNotify);
        end

        function export(this, options)
        % EXPORT Export analysis.

            arguments
                this (1, 1) mag.app.Model
                options cell
            end

            this.Analysis.export(options{:});
        end

        function task = createExportTask(this, options)
        % CREATEEXPORTTASK Create task to export analysis in the
        % background.

            arguments (Input)
                this (1, 1) mag.app.Model
                options cell
            end

            arguments (Output)
                task (1, 1) mag.app.internal.BackgroundTask
            end

            if ~this.HasAnalysis
                error("mag:app:NoAnalysis", "No analysis to export.");
            end

            task = mag.app.internal.BackgroundTask(@export, 0, [{this.Analysis}, options], ...
                Name = this.AnalysisClassName + ".export", ...
                Description = "Exporting...");
        end

        function reset(this)
        % RESET Reset analysis.
            this.setAnalysisAndNotify(feval(this.AnalysisClassName + ".empty"));
        end

        function value = get.HasAnalysis(this)
            value = ~isempty(this.Analysis) && ~isempty(this.Analysis.Results);
        end

        function range = get.TimeRange(this)

            if this.HasAnalysis && ~isempty(this.Analysis.Results)

                scienceRange = this.ScienceTimeRange;
                hkRange = this.HKTimeRange;

                range = [min(scienceRange(1), hkRange(1)), max(scienceRange(2), hkRange(2))];
            else
                range = mag.time.emptyTime(0, 2);
            end
        end

        function range = get.ScienceTimeRange(this)

            if this.HasAnalysis && ~isempty(this.Analysis.Results)
                range = this.Analysis.Results.TimeRange;
            else
                range = mag.time.emptyTime(0, 2);
            end
        end

        function range = get.HKTimeRange(this)

            if this.HasAnalysis && ~isempty(this.Analysis.Results)

                range = NaT(1, 2, TimeZone = mag.time.Constant.TimeZone);

                for hk = this.Analysis.Results.HK

                    if isempty(hk.Time)
                        continue;
                    end

                    range(1) = min(range(1), min(hk.Time, [], "omitmissing"));
                    range(2) = max(range(2), max(hk.Time, [], "omitmissing"));
                end
            else
                range = mag.time.emptyTime(0, 2);
            end
        end

        function load(this, matFile)
        % LOAD Load analysis.

            analysis = this.readAnalysis(matFile, this.AnalysisClassName);
            this.setLoadedAnalysis(analysis);
        end

        function task = createLoadTask(this, matFile)
        % CREATELOADTASK Create task to load analysis in the background.
        % Analysis is updated when task succeeds.

            arguments (Input)
                this (1, 1) mag.app.Model
                matFile (1, 1) string {mustBeFile}
            end

            arguments (Output)
                task (1, 1) mag.app.internal.BackgroundTask
            end

            task = mag.app.internal.BackgroundTask(@mag.app.Model.readAnalysis, 1, {matFile, this.AnalysisClassName}, ...
                Name = "mag.app.Model.readAnalysis", ...
                Description = "Importing...", ...
                SuccessFcn = @this.setLoadedAnalysis);
        end
    end

    methods (Static, Hidden)

        function analysis = readAnalysis(matFile, analysisClassName)
        % READANALYSIS Read first analysis of specified class from MAT
        % file.

            results = load(matFile);

            for f = string(fieldnames(results))'

                if isa(results.(f), analysisClassName)

                    analysis = results.(f);
                    return;
                end
            end

            error("mag:app:InvalidMAT", "No ""%s"" found in MAT file.", analysisClassName);
        end
    end

    methods (Access = protected)

        function setLoadedAnalysis(this, analysis)

            if ~isequal(analysis.OriginalVersion, mag.version())
                warning("mag:app:OldVersion", "Loaded analysis was generated with version %s and may be incompatible.", analysis.OriginalVersion);
            end

            this.setAnalysisAndNotify(analysis);
        end

        function setAnalysisAndNotify(this, analysis)

            this.Analysis = analysis;
            this.notify("ModelChanged");
        end
    end
end
