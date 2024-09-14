classdef (Abstract) Model < mag.mixin.SetGet
% MODEL Abstract base class for mission analysis models.

    events (NotifyAccess = private)
        % ANALYSISCHANGED Analysis changed.
        AnalysisChanged
    end

    properties (SetAccess = protected)
        % RESULTS Analysis results.
        Results {mustBeScalarOrEmpty, mustBeA(Results, ["mag.hs.Analysis", "mag.imap.Analysis"])}
    end

    methods

        % PERFORMANALYSIS Perform analysis.
        performAnalysis(this, analysisManager)
    end
end
