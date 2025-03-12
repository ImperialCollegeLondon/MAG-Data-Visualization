classdef Timestamp < mag.app.Control & mag.app.mixin.StartEndDate
% TIMESTAMP View-controller for generating "mag.imap.view.Timestamp".

    properties (Constant)
        Name = "Timestamp"
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, StartDateRow = 1, EndDateRow = 2);
        end

        function supported = isSupported(~, results)
            supported = isa(results, "mag.imap.Instrument") && results.HasScience;
        end

        function command = getVisualizeCommand(this, results)

            arguments (Input)
                this
                results (1, 1) mag.imap.Instrument
            end

            arguments (Output)
                command (1, 1) mag.app.Command
            end

            [startTime, endTime] = this.getStartEndTimes();
            results = mag.app.internal.cropResults(results, startTime, endTime);

            command = mag.app.Command(Functional = @(varargin) mag.imap.view.Timestamp(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results});
        end
    end
end
