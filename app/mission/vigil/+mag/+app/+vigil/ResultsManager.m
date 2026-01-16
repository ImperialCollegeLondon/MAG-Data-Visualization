classdef ResultsManager < mag.app.manage.ResultsManager
% RESULTSMANAGER Manager for results of Vigil analysis.

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

                if results.FOB.HasData && results.FIB.HasData
                    this.plotSensorPreview(results.FOB.Data, results.FIB.Data, LegendLabels = ["FOB", "FIB"]);
                elseif results.FOB.HasData
                    this.plotSensorPreview(results.FOB.Data, LegendLabels = "FOB");
                elseif results.FIB.HasData
                    this.plotSensorPreview(results.FIB.Data, LegendLabels = "FIB");
                end
            else
                this.reset();
            end
        end
    end
end
