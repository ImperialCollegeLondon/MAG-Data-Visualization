classdef PSD < mag.app.control.Control
% PSD View-controller for generating "mag.graphics.view.PSD".

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        StartDatePicker matlab.ui.control.DatePicker
        StartTimeField matlab.ui.control.EditField
        DurationSpinner matlab.ui.control.Spinner
    end

    methods

        function instantiate(this)

            this.Layout = uigridlayout(this.Parent, [4, 3], ColumnWidth = ["fit", "1x", "1x"]);

            % Start date.
            startLabel = uilabel(this.Layout, Text = "Start date/time:");
            startLabel.Layout.Row = 1;
            startLabel.Layout.Column = 1;

            this.StartDatePicker = uidatepicker(this.Layout);
            this.StartDatePicker.Layout.Row = 1;
            this.StartDatePicker.Layout.Column = 2;

            this.StartTimeField = uieditfield(this.Layout, Placeholder = "HH:mm:ss.SSS");
            this.StartTimeField.Layout.Row = 1;
            this.StartTimeField.Layout.Column = 3;

            % Frequency points spinner.
            durationLabel = uilabel(this.Layout, Text = "Duration (hours):");
            durationLabel.Layout.Row = 2;
            durationLabel.Layout.Column = 1;

            this.DurationSpinner = uispinner(this.Layout, Value = 1, ...
                Limits = [0, Inf], LowerLimitInclusive = true);
            this.DurationSpinner.Layout.Row = 2;
            this.DurationSpinner.Layout.Column = [2, 3];
        end

        function figures = visualize(this)

            startTime = mag.app.internal.combineDateAndTime(this.StartDatePicker.Value, this.StartTimeField.Value);
            duration = this.DurationSpinner.Value;

            figures = mag.graphics.view.PSD(results, ...
                StartTime = startTime, Duration = duration).visualizeAll();
        end
    end
end
