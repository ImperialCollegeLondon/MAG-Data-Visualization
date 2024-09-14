classdef Provider < mag.app.Provider
% PROVIDER App components provider for IMAP analyses.

    methods

        function manager = getAnalysisManager(~)
            manager = mag.app.imap.AnalysisManager();
        end

        function getVisualizationManager(~)
            manager = mag.app.imap.VisualizationManager();
        end
    end
end
