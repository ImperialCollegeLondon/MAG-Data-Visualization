classdef SignalAnalyzer < mag.app.Control
% SIGNALANALYZER View-controller for opening Signal Analyzer.

    properties (Constant)
        Name = "Signal Analyzer"
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

        function this = SignalAnalyzer(selectableInputs)
            this.SelectableInputs = selectableInputs;
        end

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Input.
            inputLabel = uilabel(this.Layout, Text = "Input:");
            inputLabel.Layout.Row = 1;
            inputLabel.Layout.Column = 1;

            this.InputDropDown = uidropdown(this.Layout, Items = this.SelectableInputs);
            this.InputDropDown.Layout.Row = 1;
            this.InputDropDown.Layout.Column = [2, 3];

            % Signal.
            signalLabel = uilabel(this.Layout, Text = "Signal:");
            signalLabel.Layout.Row = 2;
            signalLabel.Layout.Column = 1;

            this.SignalDropDown = uidropdown(this.Layout, Items = ["X", "Y", "Z"]);
            this.SignalDropDown.Layout.Row = 2;
            this.SignalDropDown.Layout.Column = [2, 3];

            % Note.
            noteLabel = uilabel(this.Layout, Text = "Note: opens Signal Analyzer app.");
            noteLabel.Layout.Row = 5;
            noteLabel.Layout.Column = [1, 3];
        end

        function supported = isSupported(~, results)
            supported = exist("signalAnalyzer", "file") && results.HasScience;
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

            command = mag.app.Command(Functional = @(varargin) signalAnalyzer(varargin{:}), ...
                PositionalArguments = {selectedData});
        end
    end
end
