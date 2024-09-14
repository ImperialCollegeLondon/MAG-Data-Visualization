classdef Provider < mag.app.Provider
% PROVIDER App components provider for IMAP analyses.

    properties (Constant)
        Model = mag.app.imap.Model()
        AnalysisManager = mag.app.imap.AnalysisManager()
        ResultsManager = mag.app.imap.ResultsManager()
        VisualizationManager = mag.app.imap.VisualizationManager()
    end
end
