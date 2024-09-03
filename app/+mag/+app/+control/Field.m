classdef Field < mag.app.control.Control
% FIELD View-controller for generating "mag.graphics.view.Field".

    properties (Access = private)
        % LAYOUT Grid layout of view-controller.
        Layout matlab.ui.container.GridLayout
        % STARTDATEPICKER Start date picker for cropping.
        StartDatePicker matlab.ui.control.DatePicker
        % STARTTIMEPICKER Start time edit field for cropping.
        StartTimeField matlab.ui.control.EditField
        % ENDDATEPICKER End date picker for cropping.
        EndDatePicker matlab.ui.control.DatePicker
        % ENDTIMEPICKER End time edit field for cropping.
        EndTimeField matlab.ui.control.EditField
        % EVENTSTREE Events checkbox tree.
        EventsTree matlab.ui.container.CheckBoxTree
    end

    methods

        function instantiate(this)

            this.Layout = uigridlayout(this.Parent, [3, 3], RowHeight = ["1x", "1x", "2x"], ColumnWidth = ["fit", "1x", "1x"]);

            % Start date.
            startLabel = uilabel(this.Layout, Text = "Start date/time:");
            startLabel.Layout.Row = 1;
            startLabel.Layout.Column = 1;

            this.StartDatePicker = uidatepicker(this.Layout);
            this.StartDatePicker.Layout.Row = 1;
            this.StartDatePicker.Layout.Column = 2;

            this.StartTimeField = uieditfield(this.Layout, Placeholder = "HH:mm:ss.SSS");
            this.StartTimeField.Layout.Row = 1;
            this.StartTimeField.Layout.Column = 3;

            % End date.
            endLabel = uilabel(this.Layout, Text = "End date/time:");
            endLabel.Layout.Row = 2;
            endLabel.Layout.Column = 1;

            this.EndDatePicker = uidatepicker(this.Layout);
            this.EndDatePicker.Layout.Row = 2;
            this.EndDatePicker.Layout.Column = 2;

            this.EndTimeField = uieditfield(this.Layout, Placeholder = "HH:mm:ss.SSS");
            this.EndTimeField.Layout.Row = 2;
            this.EndTimeField.Layout.Column = 3;

            % Events.
            eventsLabel = uilabel(this.Layout, Text = "Events:");
            eventsLabel.Layout.Row = 3;
            eventsLabel.Layout.Column = 1;

            this.EventsTree = uitree(this.Layout, "checkbox");
            this.EventsTree.Layout.Row = 3;
            this.EventsTree.Layout.Column = [2, 3];

            for e = ["Compression", "Mode", "Range"]
                uitreenode(this.EventsTree, Text = e);
            end
        end

        function figures = visualize(this)

            startTime = mag.app.internal.combineDateAndTime(this.StartDatePicker.Value, this.StartTimeField.Value);
            endTime = mag.app.internal.combineDateAndTime(this.EndDatePicker.Value, this.EndTimeField.Value);

            if isempty(this.EventsTree.CheckedNodes)
                events = string.empty();
            else
                events = {this.EventsTree.CheckedNodes.Text};
            end

            results = this.cropResults(startTime, endTime);
            figures = mag.graphics.view.Field(results, Events = events).visualizeAll();
        end
    end
end
