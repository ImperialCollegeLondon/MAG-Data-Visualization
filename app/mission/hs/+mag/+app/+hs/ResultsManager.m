classdef ResultsManager < mag.app.manage.ResultsManager
% RESULTSMANAGER Manager for results of HelioSwarm analysis.

    properties (SetAccess = private)
        ResultsLayout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            % Create ResultsLayout.
            this.ResultsLayout = uigridlayout(parent);
            this.ResultsLayout.ColumnWidth = "1x";
            this.ResultsLayout.RowHeight = "1x";

            % Create science preview.
            this.instantiateSciencePreview(this.ResultsLayout);

            % Reset.
            this.reset();
        end

        function reset(this)
            this.resetSciencePreview();
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if model.HasAnalysis && model.Analysis.Results.HasScience
                this.plotSensorPreview(model.Analysis.Results.Science.Data, LegendLabels = "");
            else
                this.reset();
            end
        end
    end
end
