classdef AT < mag.app.control.Control & mag.app.mixin.Filter
% AT View-controller for generating Aliveness Test plots.

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        PSDCheckBox matlab.ui.control.CheckBox
        PSDStartDatePicker matlab.ui.control.DatePicker
        PSDStartTimeField matlab.ui.control.EditField
        PSDDurationSpinner matlab.ui.control.Spinner
    end

    methods

        function instantiate(this)

            this.Layout = this.createDefaultGridLayout();

            % Filter.
            this.addFilterButtons(this.Layout, StartFilterRow = 1);

            % PSD.
            psdLabel = uilabel(this.Layout, Text = "Show PSD:");
            psdLabel.Layout.Row = 2;
            psdLabel.Layout.Column = 1;

            this.PSDCheckBox = uicheckbox(this.Layout, Value = 1, Text = "", ...
                ValueChangedFcn = @(~, ~) this.psdCheckboxChanged());
            this.PSDCheckBox.Layout.Row = 2;
            this.PSDCheckBox.Layout.Column = 2;

            % PSD start date.
            psdStartLabel = uilabel(this.Layout, Text = "PSD start date/time:");
            psdStartLabel.Layout.Row = 3;
            psdStartLabel.Layout.Column = 1;

            this.PSDStartDatePicker = uidatepicker(this.Layout);
            this.PSDStartDatePicker.Layout.Row = 3;
            this.PSDStartDatePicker.Layout.Column = 2;

            this.PSDStartTimeField = uieditfield(this.Layout, Placeholder = "HH:mm:ss.SSS");
            this.PSDStartTimeField.Layout.Row = 3;
            this.PSDStartTimeField.Layout.Column = 3;

            % PSD duration.
            psdDurationLabel = uilabel(this.Layout, Text = "PSD duration (hours):");
            psdDurationLabel.Layout.Row = 4;
            psdDurationLabel.Layout.Column = 1;

            this.PSDDurationSpinner = uispinner(this.Layout, Value = 1, ...
                Limits = [0, Inf], LowerLimitInclusive = true);
            this.PSDDurationSpinner.Layout.Row = 4;
            this.PSDDurationSpinner.Layout.Column = [2, 3];
        end

        function figures = visualize(this, results)

            arguments
                this
                results (1, 1) mag.IMAPAnalysis
            end

            startFilter = this.getFilters();
            psdDuration = hours(this.PSDDurationSpinner.Value);

            if this.PSDCheckBox.Value
                psdStartTime = mag.app.internal.combineDateAndTime(this.PSDStartDatePicker.Value, this.PSDStartTimeField.Value);
            else
                psdStartTime = datetime.empty();
            end

            figures = mag.graphics.sftPlots(results, Filter = startFilter, ...
                PSDStart = psdStartTime, PSDDuration = psdDuration);
        end
    end

    methods (Access = private)

        function psdCheckboxChanged(this)

            value = this.PSDCheckBox.Value;

            this.PSDStartDatePicker.Enable = value;
            this.PSDStartTimeField.Enable = value;
            this.PSDDurationSpinner.Enable = value;
        end
    end
end
