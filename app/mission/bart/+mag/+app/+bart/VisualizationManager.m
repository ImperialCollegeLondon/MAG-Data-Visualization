classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of Bartington analysis.

    properties (Constant, Access = protected)
        EmptyModel = mag.app.bart.Model.empty()
    end

    methods

        function [items, itemsData] = getVisualizationTypesAndClasses(~, model)

            arguments
                ~
                model mag.app.bart.Model {mustBeScalarOrEmpty}
            end

            itemsData = mag.app.Control.empty();

            supportedControls = [mag.app.control.Field(@mag.bart.view.Field), ...
                mag.app.control.PSD(@mag.bart.view.Spectrogram), ...
                mag.app.control.SignalAnalyzer(["Input1", "Input2"]), ...
                mag.app.control.Spectrogram(@mag.bart.view.Spectrogram), ...
                mag.app.control.WaveletAnalyzer(["Input1", "Input2"])];

            if ~isempty(model) && model.HasAnalysis

                for c = supportedControls

                    if c.isSupported(model.Analysis.Results)
                        itemsData = [itemsData, c]; %#ok<AGROW>
                    end
                end
            end

            if ~isempty(itemsData)
                items = [itemsData.Name];
            else
                items = string.empty();
            end
        end

        function figures = visualize(this, analysis)

            command = this.SelectedControl.getVisualizeCommand(analysis.Results);

            if command.NArgOut > 0
                figures = command.call();
            else

                command.call();
                figures = matlab.ui.Figure.empty();
            end
        end
    end
end
