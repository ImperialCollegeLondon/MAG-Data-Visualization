classdef (Abstract) AnalysisManager < mag.app.manage.Manager
% ANALYSISMANAGER Manager for analysis components.

    methods (Abstract)

        % GETANALYSISOPTIONS Get options to perform analysis.
        options = getAnalysisOptions(this)
    end
end
