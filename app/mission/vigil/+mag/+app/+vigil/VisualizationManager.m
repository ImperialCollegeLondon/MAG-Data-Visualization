classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of Vigil analysis.

    properties (Constant, Access = protected)
        EmptyModel = mag.app.vigil.Model.empty()
    end

    methods

        function supportedVisualizations = getSupportedVisualizations(~, ~)

            supportedVisualizations = [mag.app.control.Field(@mag.vigil.view.Field), ...
                mag.app.control.PSD(@mag.graphics.view.PSD), ...
                mag.app.control.Spectrogram(@mag.vigil.view.Spectrogram), ...
                mag.app.control.SignalAnalyzer(["FOB", "FIB"]), ...
                mag.app.control.WaveletAnalyzer(["FOB", "FIB"])];
        end
    end
end
