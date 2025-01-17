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
        AppDropDown matlab.ui.control.DropDown
        InputDropDown matlab.ui.control.DropDown
        SignalDropDown matlab.ui.control.DropDown
        NoteLabel matlab.ui.control.Label
    end

    methods

        function this = WaveletAnalyzer(selectableInputs)
            this.SelectableInputs = selectableInputs;
        end

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % App.
            appLabel = uilabel(this.Layout, Text = "App:");
            appLabel.Layout.Row = 1;
            appLabel.Layout.Column = 1;

            this.AppDropDown = uidropdown(this.Layout, Items = ["Signal Analyzer", "Time-Frequency Analyzer"]);
            this.AppDropDown.ValueChangedFcn = @(~, ~) this.appDropDownValueChanged();
            this.AppDropDown.Layout.Row = 1;
            this.AppDropDown.Layout.Column = [2, 3];

            % Input.
            inputLabel = uilabel(this.Layout, Text = "Input:");
            inputLabel.Layout.Row = 2;
            inputLabel.Layout.Column = 1;

            this.InputDropDown = uidropdown(this.Layout, Items = this.SelectableInputs);
            this.InputDropDown.Layout.Row = 2;
            this.InputDropDown.Layout.Column = [2, 3];

            % Signal.
            signalLabel = uilabel(this.Layout, Text = "Signal:");
            signalLabel.Layout.Row = 3;
            signalLabel.Layout.Column = 1;

            this.SignalDropDown = uidropdown(this.Layout, Items = ["X", "Y", "Z"]);
            this.SignalDropDown.Layout.Row = 3;
            this.SignalDropDown.Layout.Column = [2, 3];

            % Note.
            this.NoteLabel = uilabel(this.Layout, Text = "");
            this.NoteLabel.Layout.Row = 5;
            this.NoteLabel.Layout.Column = [1, 3];

            this.appDropDownValueChanged();
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
            propertyName = selectedInput + "_" + selectedSignal;

            selectedData = timetable(data.Time - data.Time(1), data.(selectedSignal), VariableNames = propertyName);

            if ~isregular(selectedData)

                frequencies = 1 ./ seconds(data.dT);
                warning("Resampling data as not uniformely sampled (%.3f ± %.3g Hz).", mode(frequencies), std(frequencies, 0, "omitmissing"));

                selectedData = resample(selectedData);
            end

            switch this.AppDropDown.Value
                case "Signal Analyzer"

                    command = mag.app.Command(Functional = @waveletSignalAnalyzer, ...
                        PositionalArguments = {selectedData.(propertyName)});
                case "Time-Frequency Analyzer"

                    command = mag.app.Command(Functional = @waveletTimeFrequencyAnalyzer, ...
                        PositionalArguments = {selectedData});
                otherwise
                    error("Unknown Wavelet Toolbox app ""%s"".", this.AppDropDown.Value);
            end
        end
    end

    methods (Access = private)

        function appDropDownValueChanged(this)
            this.NoteLabel.Text = compose("Note: opens Wavelet %s app.", this.AppDropDown.Value);
        end
    end
end
