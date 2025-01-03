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

            items = string.empty();
            itemsData = mag.app.Control.empty();

            if ~isempty(model) && model.HasAnalysis

                if model.Analysis.Results.HasScience

                    items = [items, "Spectrogram", "PSD"];
                    itemsData = [itemsData, ...
                        mag.app.control.Spectrogram(@mag.bart.view.Spectrogram), ...
                        mag.app.control.PSD(@mag.bart.view.PSD)];
                end

                if (~isempty(model.Analysis.Results.Input1) && model.Analysis.Results.Input1.HasData) || ...
                    (~isempty(model.Analysis.Results.Input2) && model.Analysis.Results.Input2.HasData)

                    items = [items, "Science"];
                    itemsData = [itemsData, ...
                        mag.app.control.Field(@mag.bart.view.Field)];
                end
            end
        end

        function figures = visualize(this, analysis)

            command = this.SelectedControl.getVisualizeCommand(analysis.Results);
            figures = command.call();
        end
    end
end
