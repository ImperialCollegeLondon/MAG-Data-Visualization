classdef VisualizationManager < mag.app.manage.VisualizationManager
% VISUALIZATIONMANAGER Manager for visualization of HelioSwarm analysis.

    methods

        function items = getVisualizationTypes(~)
            items = "Field";
        end

        function itemsData = getVisualizationClasses(~)
            itemsData = mag.app.hs.control.Field();
        end

        function figures = visualize(this, analysis)

            command = this.SelectedControl.getVisualizeCommand(analysis.Results);
            figures = command.call();
        end
    end
end
