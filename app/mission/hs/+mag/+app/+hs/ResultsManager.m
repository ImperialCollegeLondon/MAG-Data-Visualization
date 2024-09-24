classdef ResultsManager < mag.app.manage.Manager
% RESULTSMANAGER Manager for results of HelioSwarm analysis.

    properties (SetAccess = private)
        ResultsLayout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            % Create ResultsLayout.
            this.ResultsLayout = uigridlayout(parent);
            this.ResultsLayout.ColumnWidth = "1x";
            this.ResultsLayout.RowHeight = ["1x", "1x"];

            uilabel(this.ResultsLayout, Text = "Not available for HelioSwarm yet.", HorizontalAlignment = "center", VerticalAlignment = "center");

            % Reset.
            this.reset();
        end

        function reset(~)
            % do nothing
        end
    end

    methods (Access = protected)

        function modelChangedCallback(this, model, ~)

            if model.HasAnalysis && model.Analysis.Results.HasScience
                % do nothing
            else
                this.reset();
            end
        end
    end
end
