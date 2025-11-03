classdef PSD < mag.app.Control
% PSD View-controller for generating PSD view.

    properties (Constant)
        Name = "PSD"
    end

    properties (SetAccess = immutable)
        ViewType function_handle {mustBeScalarOrEmpty}
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        StartTimeSlider mag.app.component.DatetimeSlider
        DurationSpinner matlab.ui.control.Spinner
        NoiseThresholdDropDown matlab.ui.control.DropDown
        SyncYAxesCheckBox matlab.ui.control.CheckBox
    end

    methods

        function this = PSD(viewType)

            arguments
                viewType (1, 1) function_handle
            end

            this.ViewType = viewType;
        end

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);
            this.Layout.RowHeight = ["3x", "1x", "1x", "1x", "1x"];

            % Start date.
            startLabel = uilabel(this.Layout, Text = "Start date/time:");
            startLabel.Layout.Row = 1;
            startLabel.Layout.Column = 1;

            this.StartTimeSlider = mag.app.component.DatetimeSlider(this.Layout);
            this.StartTimeSlider.Layout.Row = 1;
            this.StartTimeSlider.Layout.Column = [2, 3];

            if ~any(isnat(this.Model.ScienceTimeRange))
                this.StartTimeSlider.Limits = this.Model.ScienceTimeRange;
            end

            % Duration.
            durationLabel = uilabel(this.Layout, Text = "Duration (hours):");
            durationLabel.Layout.Row = 2;
            durationLabel.Layout.Column = 1;

            this.DurationSpinner = uispinner(this.Layout, Value = 1, ...
                Limits = [0, Inf]);
            this.DurationSpinner.Layout.Row = 2;
            this.DurationSpinner.Layout.Column = [2, 3];

            % Noise threshold.
            noiseThresholdLabel = uilabel(this.Layout, Text = "Noise threshold:");
            noiseThresholdLabel.Layout.Row = 3;
            noiseThresholdLabel.Layout.Column = 1;

            this.NoiseThresholdDropDown = uidropdown(this.Layout, Items = ["Default", "HelioSwarm"]);
            this.NoiseThresholdDropDown.Layout.Row = 3;
            this.NoiseThresholdDropDown.Layout.Column = [2, 3];

            % Sync y-axes.
            this.SyncYAxesCheckBox = uicheckbox(this.Layout, Text = "Sync y-axes");
            this.SyncYAxesCheckBox.Layout.Row = 4;
            this.SyncYAxesCheckBox.Layout.Column = 2;

            % Note.
            noteLabel = uilabel(this.Layout, Text = "Note: does not support hybrid instrument modes.");
            noteLabel.Layout.Row = 5;
            noteLabel.Layout.Column = [1, 3];
        end

        function supported = isSupported(~, results)
            supported = results.HasScience;
        end

        function command = getVisualizeCommand(this, results)

            arguments (Input)
                this
                results (1, 1) mag.Instrument
            end

            arguments (Output)
                command (1, 1) mag.app.Command
            end

            startTime = this.StartTimeSlider.SelectedTime;
            duration = hours(this.DurationSpinner.Value);

            switch this.NoiseThresholdDropDown.Value
                case "HelioSwarm"

                    noiseThreshold = {"NoiseThreshold", mag.graphics.chart.Function(Callable = @mag.hs.view.piecewiseNoiseThreshold, ...
                        LineStyle = "--", Color = "black")};
                otherwise % including "Default"
                    noiseThreshold = {};
            end

            command = mag.app.Command(Functional = @(varargin) this.ViewType(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results}, ...
                NamedArguments = struct(noiseThreshold{:}, Start = startTime, Duration = duration, SyncYAxes = this.SyncYAxesCheckBox.Value));
        end
    end
end
