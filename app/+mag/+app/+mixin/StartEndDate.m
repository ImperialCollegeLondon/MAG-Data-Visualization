classdef (Abstract, HandleCompatible) StartEndDate
% STARTENDDATE Add support for start and end date selection.

    properties (SetAccess = protected)
        StartDatePicker matlab.ui.control.DatePicker
        StartTimeField matlab.ui.control.EditField
        EndDatePicker matlab.ui.control.DatePicker
        EndTimeField matlab.ui.control.EditField
    end

    methods (Access = protected)

        function addStartEndDateButtons(this, parent, startDateRow, endDateRow, initialColumn)

            arguments
                this
                parent (1, 1) matlab.ui.container.GridLayout
                startDateRow (1, 1) double
                endDateRow (1, 1) double
                initialColumn (1, 1) double = 0
            end

            % Start date.
            startLabel = uilabel(parent, Text = "Start date/time:");
            startLabel.Layout.Row = startDateRow;
            startLabel.Layout.Column = initialColumn + 1;

            this.StartDatePicker = uidatepicker(parent);
            this.StartDatePicker.Layout.Row = startDateRow;
            this.StartDatePicker.Layout.Column = initialColumn + 2;

            this.StartTimeField = uieditfield(parent, Placeholder = "HH:mm:ss.SSS");
            this.StartTimeField.Layout.Row = startDateRow;
            this.StartTimeField.Layout.Column = initialColumn + 3;

            % End date.
            endLabel = uilabel(parent, Text = "End date/time:");
            endLabel.Layout.Row = endDateRow;
            endLabel.Layout.Column = initialColumn + 1;

            this.EndDatePicker = uidatepicker(parent);
            this.EndDatePicker.Layout.Row = endDateRow;
            this.EndDatePicker.Layout.Column = initialColumn + 2;

            this.EndTimeField = uieditfield(parent, Placeholder = "HH:mm:ss.SSS");
            this.EndTimeField.Layout.Row = endDateRow;
            this.EndTimeField.Layout.Column = initialColumn + 3;
        end

        function [startTime, endTime] = getStartEndTimes(this)

            startTime = mag.app.internal.combineDateAndTime(this.StartDatePicker.Value, this.StartTimeField.Value);
            endTime = mag.app.internal.combineDateAndTime(this.EndDatePicker.Value, this.EndTimeField.Value);
        end
    end
end
