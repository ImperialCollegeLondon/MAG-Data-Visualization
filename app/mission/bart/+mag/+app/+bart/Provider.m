classdef Provider < mag.app.Provider
% PROVIDER App components provider for Bartington analyses.

    methods

        function model = getModel(~)
            model = mag.app.bart.Model();
        end

        function manager = getAnalysisManager(~)
            manager = mag.app.bart.AnalysisManager();
        end

        function manager = getResultsManager(~)
            manager = mag.app.bart.ResultsManager();
        end

        function manager = getExportManager(~)
            manager = mag.app.bart.ExportManager();
        end

        function manager = getVisualizationManager(~)
            manager = mag.app.bart.VisualizationManager();
        end
    end
end
