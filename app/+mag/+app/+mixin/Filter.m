classdef (Abstract, HandleCompatible) Filter
% FILTER Add support for filtering of data.

    properties (SetAccess = protected)
        StartFilterSpinner matlab.ui.control.Spinner
    end

    methods (Access = protected)

        function addFilterButtons(this, parent, options)

            arguments
                this
                parent (1, 1) matlab.ui.container.GridLayout
                options.StartFilterRow (1, 1) double
                options.StartFilterLabelColumn (1, 1) double = 1
                options.StartFilterSpinnerColumn (1, :) double = [2, 3]
            end

            filterLabel = uilabel(parent, Text = "Filter (minutes):");
            filterLabel.Layout.Row = options.StartFilterRow;
            filterLabel.Layout.Column = options.StartFilterLabelColumn;

            this.StartFilterSpinner = uispinner(parent, Value = 1, Limits = [0, Inf]);
            this.StartFilterSpinner.Layout.Row = options.StartFilterRow;
            this.StartFilterSpinner.Layout.Column = options.StartFilterSpinnerColumn;
        end

        function startFilter = getFilters(this)
            startFilter = minutes(this.StartFilterSpinner.Value);
        end
    end
end
