classdef AT < mag.app.Control & mag.app.mixin.Filter
% AT View-controller for generating Aliveness Test plots.

    properties (Constant)
        Name = "AT/SFT"
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        CheckBoxLayout matlab.ui.container.GridLayout
        TimestampCheckBox matlab.ui.control.CheckBox
        SpectrogramCheckBox matlab.ui.control.CheckBox
        PSDCheckBox matlab.ui.control.CheckBox
        PSDStartDatePicker matlab.ui.control.DatePicker
        PSDStartTimeField matlab.ui.control.EditField
        PSDDurationSpinner matlab.ui.control.Spinner
    end

    methods

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Filter.
            this.addFilterButtons(this.Layout, StartFilterRow = 1);

            % Check-boxes.
            this.CheckBoxLayout = uigridlayout(this.Layout, [1, 3], ColumnWidth = ["fit", "fit", "fit"]);
            this.CheckBoxLayout.Layout.Row = 2;
            this.CheckBoxLayout.Layout.Column = [2, 3];

            this.TimestampCheckBox = uicheckbox(this.CheckBoxLayout, Value = 0, ...
                Text = "Timestamp analysis");
            this.TimestampCheckBox.Layout.Row = 1;
            this.TimestampCheckBox.Layout.Column = 1;

            this.SpectrogramCheckBox = uicheckbox(this.CheckBoxLayout, Value = 1, ...
                Text = "Spectrogram");
            this.SpectrogramCheckBox.Layout.Row = 1;
            this.SpectrogramCheckBox.Layout.Column = 2;

            this.PSDCheckBox = uicheckbox(this.CheckBoxLayout, Value = 1, Text = "PSD", ...
                ValueChangedFcn = @(~, ~) this.psdCheckboxChanged());
            this.PSDCheckBox.Layout.Row = 1;
            this.PSDCheckBox.Layout.Column = 3;

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

        function supported = isSupported(~, results)
            supported = results.HasScience;
        end

        function command = getVisualizeCommand(this, results)

            arguments (Input)
                this
                results (1, 1) mag.imap.Analysis
            end

            arguments (Output)
                command (1, 1) mag.app.Command
            end

            startFilter = this.getFilters();
            psdDuration = hours(this.PSDDurationSpinner.Value);

            if this.PSDCheckBox.Value
                psdStartTime = mag.app.internal.combineDateAndTime(this.PSDStartDatePicker.Value, this.PSDStartTimeField.Value);
            else
                psdStartTime = datetime.empty();
            end

            command = mag.app.Command(Functional = @mag.imap.view.sftPlots, ...
                PositionalArguments = {results}, ...
                NamedArguments = struct(Filter = startFilter, PSDStart = psdStartTime, PSDDuration = psdDuration, ...
                Spectrogram = this.SpectrogramCheckBox.Value, TimestampAnalysis = this.TimestampCheckBox.Value));
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


