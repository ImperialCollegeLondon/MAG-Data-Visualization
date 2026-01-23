classdef Provider < mag.app.Provider
% PROVIDER App components provider for Vigil analyses.

    methods

        function model = getModel(~)
            model = mag.app.vigil.Model();
        end

        function manager = getAnalysisManager(~)
            manager = mag.app.vigil.AnalysisManager();
        end

        function manager = getResultsManager(~)
            manager = mag.app.vigil.ResultsManager();
        end

        function manager = getExportManager(~)
            manager = mag.app.vigil.ExportManager();
        end

        function manager = getVisualizationManager(~)
            manager = mag.app.vigil.VisualizationManager();
        end
    end
end
