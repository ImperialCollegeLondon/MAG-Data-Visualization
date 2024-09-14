classdef (Abstract) Model < mag.mixin.SetGet
% MODEL Abstract base class for mission analysis models.

    events (NotifyAccess = private)
        % ANALYSISCHANGED Analysis changed.
        AnalysisChanged
    end

    properties (SetAccess = protected)
        % RESULTS Analysis results.
        Results {mustBeScalarOrEmpty, mustBeA(Results, ["mag.hs.Analysis", "mag.imap.Analysis"])} = mag.imap.Analysis.empty()
    end

    methods

        % PERFORM Perform analysis.
        perform(this, analysisManager)
    end
end
