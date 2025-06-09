classdef HK < mag.app.Control & mag.app.mixin.StartEndDate
% HK View-controller for generating housekeeping view.

    properties (Constant)
        Name = "HK"
    end

    properties (SetAccess = immutable)
        ViewType function_handle {mustBeScalarOrEmpty}
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
    end

    methods

        function this = HK(viewType)

            arguments
                viewType (1, 1) function_handle
            end

            this.ViewType = viewType;
        end

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, StartDateRow = 1, EndDateRow = 2);
        end

        function supported = isSupported(~, results)
            supported = results.HasHK && any(results.HK.isPlottable());
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

            command = mag.app.Command(Functional = @(varargin) this.ViewType(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results});
        end
    end
end
