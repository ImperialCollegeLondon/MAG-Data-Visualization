classdef ResultsManager < mag.app.manage.ResultsManager
% RESULTSMANAGER Manager for results of HENON analysis.

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

                if results.Outboard.HasData && results.Inboard.HasData
                    this.plotSensorPreview(results.Outboard.Data, results.Inboard.Data, LegendLabels = ["Outboard", "Inboard"]);
                elseif results.Outboard.HasData
                    this.plotSensorPreview(results.Outboard.Data, LegendLabels = "Outboard");
                elseif results.Inboard.HasData
                    this.plotSensorPreview(results.Inboard.Data, LegendLabels = "Inboard");
                end
            else
                this.reset();
            end
        end
    end
end
