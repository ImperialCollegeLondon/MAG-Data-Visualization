classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of Bartington analysis.

    properties (Constant, Access = protected)
        EmptyModel = mag.app.bart.Model.empty()
    end

    methods

        function supportedVisualizations = getSupportedVisualizations(~, ~)

            supportedVisualizations = [mag.app.control.Field(@mag.bart.view.Field), ...
                mag.app.control.PSD(@mag.bart.view.PSD), ...
                mag.app.control.Spectrogram(@mag.bart.view.Spectrogram), ...
                mag.app.control.SignalAnalyzer(["Input1", "Input2"]), ...
                mag.app.control.WaveletAnalyzer(["Input1", "Input2"])];
        end
    end
end
