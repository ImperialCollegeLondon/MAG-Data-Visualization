classdef (Abstract) Model < mag.mixin.SetGet
% MODEL Abstract base class for mission analysis models.

    events
        % ANALYSISCHANGED Analysis changed.
        AnalysisChanged
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
    end

    methods (Abstract)

        % ANALYZE Perform analysis.
        analyze(this, options)

        % LOAD Load analysis.
        load(this, matFile)

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
                range = this.Analysis.Results.TimeRange;
            else
                range = mag.time.emptyTime(0, 2);
            end
        end
    end

    methods (Access = protected)

        function setAnalysisAndNotify(this, analysis)

            this.Analysis = analysis;
            this.notify("AnalysisChanged");
        end
    end
end
