classdef (Abstract, HandleCompatible) StartEndDate
% STARTENDDATE Add support for start and end date selection.

    properties (SetAccess = protected)
        StartDatePicker matlab.ui.control.DatePicker
        StartTimeField matlab.ui.control.EditField
        EndDatePicker matlab.ui.control.DatePicker
        EndTimeField matlab.ui.control.EditField
    end

    methods (Access = protected)

        function addStartEndDateButtons(this, parent, options)

            arguments
                this
                parent (1, 1) matlab.ui.container.GridLayout
                options.StartDateRow (1, 1) double
                options.StartDateLabelColumn (1, :) double = 1
                options.StartDatePickerColumn (1, :) double = 2
                options.StartDateFieldColumn (1, :) double = 3
                options.EndDateRow (1, 1) double
                options.EndDateLabelColumn (1, :) double = 1
                options.EndDatePickerColumn (1, :) double = 2
                options.EndDateFieldColumn (1, :) double = 3
            end

            % Start date.
            startLabel = uilabel(parent, Text = "Start date/time:");
            startLabel.Layout.Row = options.StartDateRow;
            startLabel.Layout.Column = options.StartDateLabelColumn;

            this.StartDatePicker = uidatepicker(parent);
            this.StartDatePicker.Layout.Row = options.StartDateRow;
            this.StartDatePicker.Layout.Column = options.StartDatePickerColumn;

            this.StartTimeField = uieditfield(parent, Placeholder = "HH:mm:ss.SSS");
            this.StartTimeField.Layout.Row = options.StartDateRow;
            this.StartTimeField.Layout.Column = options.StartDateFieldColumn;

            % End date.
            endLabel = uilabel(parent, Text = "End date/time:");
            endLabel.Layout.Row = options.EndDateRow;
            endLabel.Layout.Column = options.EndDateLabelColumn;

            this.EndDatePicker = uidatepicker(parent);
            this.EndDatePicker.Layout.Row = options.EndDateRow;
            this.EndDatePicker.Layout.Column = options.EndDatePickerColumn;

            this.EndTimeField = uieditfield(parent, Placeholder = "HH:mm:ss.SSS");
            this.EndTimeField.Layout.Row = options.EndDateRow;
            this.EndTimeField.Layout.Column = options.EndDateFieldColumn;
        end

        function [startTime, endTime] = getStartEndTimes(this)

            startTime = mag.app.internal.combineDateAndTime(this.StartDatePicker.Value, this.StartTimeField.Value);
            endTime = mag.app.internal.combineDateAndTime(this.EndDatePicker.Value, this.EndTimeField.Value);
        end
    end
end
