classdef (Abstract) Model < mag.mixin.SetGet
% MODEL Abstract base class for mission analysis models.

    events
        % ANALYSISCHANGED Analysis changed.
        AnalysisChanged
    end

    properties (SetAccess = protected)
        % ANALYSIS Analysis results.
        Analysis {mustBeScalarOrEmpty, mustBeA(Analysis, ["mag.hs.Analysis", "mag.imap.Analysis"])} = mag.imap.Analysis.empty()
    end

    properties (Dependent, SetAccess = private)
        % HASANALYSIS Logical denoting whether analysis is available.
        HasAnalysis (1, 1) logical
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
    end
end
