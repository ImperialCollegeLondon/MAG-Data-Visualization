classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of HelioSwarm analysis.

    properties (Constant, Access = protected)
        EmptyModel = mag.app.hs.Model.empty()
    end

    methods

        function supportedVisualizations = getSupportedVisualizations(~, ~)

            supportedVisualizations = [mag.app.control.Field(@mag.hs.view.Field), ...
                mag.app.control.PSD(@mag.hs.view.PSD), ...
                mag.app.control.Spectrogram(@mag.hs.view.Spectrogram), ...
                mag.app.control.SignalAnalyzer("Science"), ...
                mag.app.control.WaveletAnalyzer("Science")];
        end
    end
end
