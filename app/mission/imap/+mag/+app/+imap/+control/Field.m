classdef Field < mag.app.control.Control & mag.app.mixin.StartEndDate
% FIELD View-controller for generating "mag.imap.view.Field".

    properties (Constant, Access = private)
        % SUPPORTEDEVENTS Events supported by "mag.imap.view.Field".
        SupportedEvents (1, 3) string = ["Compression", "Mode", "Range"]
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        EventsTree matlab.ui.container.CheckBoxTree
    end

    methods

        function instantiate(this)

            this.Layout = this.createDefaultGridLayout();

            % Start and end dates.
            this.addStartEndDateButtons(this.Layout, StartDateRow = 1, EndDateRow = 2);

            % Events.
            eventsLabel = uilabel(this.Layout, Text = "Events:");
            eventsLabel.Layout.Row = 3;
            eventsLabel.Layout.Column = 1;

            this.EventsTree = uitree(this.Layout, "checkbox");
            this.EventsTree.Layout.Row = [3, 4];
            this.EventsTree.Layout.Column = [2, 3];

            for e = this.SupportedEvents
                uitreenode(this.EventsTree, Text = e);
            end
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

            if isempty(this.EventsTree.CheckedNodes)
                events = string.empty();
            else
                events = {this.EventsTree.CheckedNodes.Text};
            end

            results = mag.app.internal.cropResults(results, startTime, endTime);

            command = mag.app.Command(Functional = @(varargin) mag.imap.view.Field(varargin{:}).visualizeAll(), ...
                PositionalArguments = {results}, ...
                NamedArguments = struct(Events = events));
        end
    end
end
