classdef Spectrogram < mag.app.Control & mag.app.mixin.StartEndDate
% SPECTROGRAM View-controller for generating spectrogram view.

    properties (Constant)
        Name = "Spectrogram"
    end

    properties (SetAccess = immutable)
        ViewType function_handle {mustBeScalarOrEmpty}
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        FrequencyPointsSpinner matlab.ui.control.Spinner
        OverlapSpinner matlab.ui.control.Spinner
        WindowSpinner matlab.ui.control.Spinner
    end

    methods

        function this = Spectrogram(viewType)

            arguments
                viewType (1, 1) function_handle
            end

            this.ViewType = viewType;
        end

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, Limits = this.Model.TimeRange);

            % Frequency points.
            frequencyPointsLabel = uilabel(this.Layout, Text = "Frequency points:", ...
                Tooltip = "Number of discrete Fourier transform points.");
            frequencyPointsLabel.Layout.Row = 3;
            frequencyPointsLabel.Layout.Column = 1;

            this.FrequencyPointsSpinner = uispinner(this.Layout, Value = 256, ...
                Step = 1, Limits = [0, Inf]);
            this.FrequencyPointsSpinner.Layout.Row = 3;
            this.FrequencyPointsSpinner.Layout.Column = [2, 3];

            % Overlap.
            overlapLabel = uilabel(this.Layout, Text = "Overlap:", ...
                Tooltip = "Overlap between segments.");
            overlapLabel.Layout.Row = 4;
            overlapLabel.Layout.Column = 1;

            this.OverlapSpinner = uispinner(this.Layout, Value = double.empty(), AllowEmpty = true, ...
                Step = 0.1, ValueDisplayFormat = "%.2f", ...
                Limits = [0, 1], LowerLimitInclusive = false, ...
                Placeholder = this.DynamicPlaceholder);
            this.OverlapSpinner.Layout.Row = 4;
            this.OverlapSpinner.Layout.Column = [2, 3];

            % Window.
            windowLabel = uilabel(this.Layout, Text = "Window:", ...
                Tooltip = "Divide data into segments of this length and window each segment with a Hamming window.");
            windowLabel.Layout.Row = 5;
            windowLabel.Layout.Column = 1;

            this.WindowSpinner = uispinner(this.Layout, Value = double.empty(), AllowEmpty = true, ...
                Step = 1, Limits = [0, Inf], LowerLimitInclusive = false, ...
                Placeholder = this.DynamicPlaceholder);
            this.WindowSpinner.Layout.Row = 5;
            this.WindowSpinner.Layout.Column = [2, 3];
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

            [startTime, endTime] = this.getStartEndTimes();
            frequencyPoints = this.FrequencyPointsSpinner.Value;

            if isempty(this.OverlapSpinner.Value)
                overlap = missing();
            else
                overlap = this.OverlapSpinner.Value;
            end

            if isempty(this.WindowSpinner.Value)
                window = missing();
            else
                window = this.WindowSpinner.Value;
            end

            results = mag.app.internal.cropResults(results, startTime, endTime);

            command = mag.app.Command(Functional = @(varargin) this.ViewType(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results}, ...
                NamedArguments = struct(FrequencyPoints = frequencyPoints, Overlap = overlap, Window = window));
        end
    end
end
