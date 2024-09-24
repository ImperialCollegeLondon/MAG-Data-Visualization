classdef (Abstract) Provider < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% PROVIDER Abstract base class for app components providers.

    methods (Abstract)

        % GETMODEL Retrieve model.
        model = getModel(this)

        % GETANALYSISMANAGER Retrieve analysis manager.
        manager = getAnalysisManager(this)

        % GETRESULTSMANAGER Retrieve results manager.
        manager = getResultsManager(this)

        % GETEXPORTMANAGER Retrieve export manager.
        manager = getExportManager(this)

        % GETVISUALIZATIONMANAGER Retrieve visualization manager.
        manager = getVisualizationManager(this)
    end
end
