classdef ResultsManager < mag.app.manage.ResultsManager
% RESULTSMANAGER Manager for results of HelioSwarm analysis.

    methods (Access = protected)

        function plotPreview(this, results)
            this.plotSensorPreview(results.Science.Data, LegendLabels = "");
        end
    end
end
