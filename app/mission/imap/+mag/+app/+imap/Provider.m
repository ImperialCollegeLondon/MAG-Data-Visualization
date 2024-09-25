classdef Provider < mag.app.Provider
% PROVIDER App components provider for IMAP analyses.

    methods

        function model = getModel(~)
            model = mag.app.imap.Model();
        end

        function manager = getAnalysisManager(~)
            manager = mag.app.imap.AnalysisManager();
        end

        function manager = getResultsManager(~)
            manager = mag.app.imap.ResultsManager();
        end

        function manager = getExportManager(~)
            manager = mag.app.imap.ExportManager();
        end

        function manager = getVisualizationManager(~)
            manager = mag.app.imap.VisualizationManager();
        end
    end
end
