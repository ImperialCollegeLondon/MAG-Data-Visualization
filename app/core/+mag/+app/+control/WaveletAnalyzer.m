classdef WaveletAnalyzer < mag.app.Control
% WAVELETANALYZER View-controller for opening Wavelet Time-Frequency
% Analyzer.

    properties (Constant)
        Name = "Wavelet Analyzer"
    end

    properties (SetAccess = immutable)
        SelectableInputs (1, :) string
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        InputDropDown matlab.ui.control.DropDown
        SignalDropDown matlab.ui.control.DropDown
    end

    methods

        function this = WaveletAnalyzer(selectableInputs)
            this.SelectableInputs = selectableInputs;
        end

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Input.
            inputLabel = uilabel(this.Layout, Text = "Input:");
            inputLabel.Layout.Row = 1;
            inputLabel.Layout.Column = 1;

            this.InputDropDown = uidropdown(this.Layout);
            this.InputDropDown.Items = this.SelectableInputs;
            this.InputDropDown.Layout.Row = 1;
            this.InputDropDown.Layout.Column = [2, 3];

            % Signal.
            signalLabel = uilabel(this.Layout, Text = "Signal:");
            signalLabel.Layout.Row = 2;
            signalLabel.Layout.Column = 1;

            this.SignalDropDown = uidropdown(this.Layout);
            this.SignalDropDown.Items = ["X", "Y", "Z"];
            this.SignalDropDown.Layout.Row = 2;
            this.SignalDropDown.Layout.Column = [2, 3];
        end

        function supported = isSupported(~, results)
            supported = exist("waveletTimeFrequencyAnalyzer", "file") && results.HasScience;
        end

        function command = getVisualizeCommand(this, results)

            arguments (Input)
                this
                results (1, 1) mag.Instrument
            end

            arguments (Output)
                command (1, 1) mag.app.Command
            end

            selectedInput = string(this.InputDropDown.Value);
            selectedSignal = string(this.SignalDropDown.Value);

            data = results.(selectedInput);
            selectedData = timetable(data.Time - data.Time(1), data.(selectedSignal), VariableNames = selectedInput + "_" + selectedSignal);

            if ~isregular(selectedData)

                frequencies = 1 ./ seconds(data.dT);
                warning("Resampling data as not uniformely sampled (%.3f ± %.3g Hz).", mode(frequencies), std(frequencies, 0, "omitmissing"));

                selectedData = resample(selectedData);
            end

            command = mag.app.Command(Functional = @(varargin) waveletTimeFrequencyAnalyzer(varargin{:}), ...
                PositionalArguments = {selectedData});
        end
    end
end
