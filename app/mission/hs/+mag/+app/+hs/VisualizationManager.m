classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of HelioSwarm analysis.

    methods

        function [items, itemsData] = getVisualizationTypesAndClasses(~, model)

            arguments
                ~
                model mag.app.hs.Model {mustBeScalarOrEmpty}
            end

            items = string.empty();
            itemsData = mag.app.Control.empty();

            if ~isempty(model) && model.HasAnalysis

                if (~isempty(model.Analysis.Results.Primary) && model.Analysis.Results.Primary.HasData) || ...
                        (~isempty(model.Analysis.Results.Secondary) && model.Analysis.Results.Secondary.HasData)

                    items = [items, "Science"];
                    itemsData = [itemsData, mag.app.hs.control.Field()];
                end
            end
        end

        function figures = visualize(this, analysis)

            command = this.SelectedControl.getVisualizeCommand(analysis.Results);
            figures = command.call();
        end
    end
end
