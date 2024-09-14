classdef (Abstract) Provider < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% PROVIDER Abstract base class for app components providers.

    properties (Abstract, Constant)
        % MODEL Retrieve model.
        Model (1, 1) mag.app.Model
        % ANALYSISMANAGER Retrieve analysis manager.
        AnalysisManager (1, 1) mag.app.Manager
        % RESULTSMANAGER Retrieve results manager.
        ResultsManager (1, 1) mag.app.Manager
        % VISUALIZATIONMANAGER Retrieve visualization manager.
        VisualizationManager (1, 1) mag.app.Manager
    end
end
