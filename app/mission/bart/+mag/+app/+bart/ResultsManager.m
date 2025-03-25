classdef ResultsManager < mag.app.manage.ResultsManager
% RESULTSMANAGER Manager for results of Bartington analysis.

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

                results = model.Analysis.Results;

                if results.Input1.HasData && results.Input2.HasData
                    this.plotSensorPreview(results.Input1.Data, results.Input2.Data, LegendLabels = ["Input1", "Input2"]);
                elseif results.Input1.HasData
                    this.plotSensorPreview(results.Input1.Data, LegendLabels = "Input1");
                elseif results.Input2.HasData
                    this.plotSensorPreview(results.Input2.Data, LegendLabels = "Input2");
                end
            else
                this.reset();
            end
        end
    end
end
