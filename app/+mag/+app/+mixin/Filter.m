classdef (Abstract, HandleCompatible) Filter
% FILTER Add support for filtering of data.

    properties (SetAccess = protected)
        StartFilterSpinner matlab.ui.control.Spinner
    end

    methods (Access = protected)

        function addFilterButtons(this, parent, startFilterRow, initialColumn)

            arguments
                this
                parent (1, 1) matlab.ui.container.GridLayout
                startFilterRow (1, 1) double
                initialColumn (1, 1) double = 0
            end

            filterLabel = uilabel(parent, Text = "Filter (minutes):");
            filterLabel.Layout.Row = startFilterRow;
            filterLabel.Layout.Column = initialColumn + 1;

            this.StartFilterSpinner = uispinner(parent, Value = 1, Limits = [0, Inf]);
            this.StartFilterSpinner.Layout.Row = startFilterRow;
            this.StartFilterSpinner.Layout.Column = initialColumn + [2, 3];
        end

        function startFilter = getFilters(this)
            startFilter = minutes(this.StartFilterSpinner.Value);
        end
    end
end
