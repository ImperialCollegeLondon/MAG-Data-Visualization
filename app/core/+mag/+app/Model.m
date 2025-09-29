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

    methods (Abstract)

        % ANALYZE Perform analysis.
        analyze(this, options)

        % EXPORT Export analysis.
        export(this, options)

        % RESET Reset analysis.
        reset(this)
    end

    methods

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

            results = load(matFile);

            for f = string(fieldnames(results))'

                analysis = results.(f);

                if isa(analysis, this.AnalysisClassName)

                    if ~isequal(analysis.OriginalVersion, mag.version())
                        warning("mag:app:OldVersion", "Loaded analysis was generated with version %s and may be incompatible.", analysis.OriginalVersion);
                    end

                    this.setAnalysisAndNotify(analysis);
                    return;
                end
            end

            error("mag:app:InvalidMAT", "No ""%s"" found in MAT file.", this.AnalysisClassName);
        end
    end

    methods (Access = protected)

        function setAnalysisAndNotify(this, analysis)

            this.Analysis = analysis;
            this.notify("ModelChanged");
        end
    end
end
