classdef Provider < mag.app.Provider
% PROVIDER App components provider for HelioSwarm analyses.

    methods

        function model = getModel(~)
            model = mag.app.hs.Model();
        end

        function manager = getAnalysisManager(~)
            manager = mag.app.hs.AnalysisManager();
        end

        function manager = getResultsManager(~)
            manager = mag.app.hs.ResultsManager();
        end

        function manager = getExportManager(~)
            manager = mag.app.imap.ExportManager();
        end

        function manager = getVisualizationManager(~)
            manager = mag.app.imap.VisualizationManager();
        end
    end
end
