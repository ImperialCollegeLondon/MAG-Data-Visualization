classdef Field < mag.app.Control & mag.app.mixin.StartEndDate
% FIELD View-controller for generating "mag.bart.view.Field".

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, StartDateRow = 1, EndDateRow = 2);
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
            results = mag.app.internal.cropResults(results, startTime, endTime);

            command = mag.app.Command(Functional = @(varargin) mag.bart.view.Field(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results});
        end
    end
end
