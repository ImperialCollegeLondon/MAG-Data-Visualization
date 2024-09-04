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

            this.Layout = this.createDefaultGridLayout();

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

            % Duration.
            durationLabel = uilabel(this.Layout, Text = "Duration (hours):");
            durationLabel.Layout.Row = 2;
            durationLabel.Layout.Column = 1;

            this.DurationSpinner = uispinner(this.Layout, Value = 1, ...
                Limits = [0, Inf], LowerLimitInclusive = true);
            this.DurationSpinner.Layout.Row = 2;
            this.DurationSpinner.Layout.Column = [2, 3];
        end

        function figures = visualize(this, results)

            arguments
                this
                results (1, 1) mag.Instrument
            end

            startTime = mag.app.internal.combineDateAndTime(this.StartDatePicker.Value, this.StartTimeField.Value);
            duration = hours(this.DurationSpinner.Value);

            figures = mag.graphics.view.PSD(results, ...
                Start = startTime, Duration = duration).visualizeAll();
        end
    end
end
