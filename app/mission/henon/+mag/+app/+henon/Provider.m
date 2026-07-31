classdef Provider < mag.app.Provider
% PROVIDER App components provider for HENON analyses.

    methods

        function model = getModel(~)
            model = mag.app.henon.Model();
        end

        function manager = getAnalysisManager(~)
            manager = mag.app.henon.AnalysisManager();
        end

        function manager = getResultsManager(~)
            manager = mag.app.henon.ResultsManager();
        end

        function manager = getExportManager(~)
            manager = mag.app.henon.ExportManager();
        end

        function manager = getVisualizationManager(~)
            manager = mag.app.henon.VisualizationManager();
        end
    end
end
