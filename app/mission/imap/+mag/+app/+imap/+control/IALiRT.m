classdef IALiRT < mag.app.Control & mag.app.mixin.StartEndDate
% IALIRT View-controller for generating "mag.imap.view.Field" for I-ALiRT
% data.

    properties (Constant)
        Name = "I-ALiRT"
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
    end

    methods

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, Limits = this.Model.TimeRange);
        end

        function supported = isSupported(~, results)

            if ~isa(results, "mag.imap.Instrument")

                supported = false;
                return;
            end

            iALiRT = results.IALiRT;

            supported = ~isempty(iALiRT) && iALiRT.HasScience && ...
                ((~isempty(iALiRT.Primary) && iALiRT.Primary.HasData) || (~isempty(iALiRT.Secondary) && iALiRT.Secondary.HasData));
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
            iALiRT = mag.imap.Instrument(Science = results.IALiRT.Science);

            command = mag.app.Command(Functional = @(varargin) mag.imap.view.Field(varargin{:}).visualizeAll(), ...
                PositionalArguments = {iALiRT});
        end
    end
end
