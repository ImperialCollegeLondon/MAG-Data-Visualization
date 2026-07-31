classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of HENON analysis.

    properties (Constant, Access = protected)
        EmptyModel = mag.app.henon.Model.empty()
    end

    methods

        function supportedVisualizations = getSupportedVisualizations(~, ~)

            supportedVisualizations = [mag.app.control.Field(@mag.henon.view.Field), ...
                mag.app.control.PSD(@mag.graphics.view.PSD), ...
                mag.app.control.Spectrogram(@mag.henon.view.Spectrogram), ...
                mag.app.control.SignalAnalyzer(["Outboard", "Inboard"]), ...
                mag.app.control.WaveletAnalyzer(["Outboard", "Inboard"])];
        end
    end
end
