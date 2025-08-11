classdef DatetimeRangeSlider < matlab.ui.componentcontainer.ComponentContainer
% DATETIMERANGESLIDER Slider for range of datetimes (start and end times).

    properties (SetAccess = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
        Slider matlab.ui.control.RangeSlider
        StartDatePicker matlab.ui.control.DatePicker
        StartTimeField matlab.ui.control.EditField
        EndDatePicker matlab.ui.control.DatePicker
        EndTimeField matlab.ui.control.EditField
    end

    properties (Constant)
        % SLIDERLIMITS Range of slider values.
        SliderLimits (1, 2) double = [0, 100]
    end

    properties (SetObservable)
        % LIMITS Limits of slider.
        Limits (1, 2) datetime = [datetime("yesterday", TimeZone = "UTC"), datetime("tomorrow", TimeZone = "UTC")]
    end

    properties (Dependent, SetAccess = private)
        % STARTTIME Selected start datetime.
        StartTime (1, 1) datetime
        % ENDTIME Selected end datetime.
        EndTime (1, 1) datetime
    end

    methods

        function comp = DatetimeRangeSlider(varargin)

            comp = comp@matlab.ui.componentcontainer.ComponentContainer(varargin{:});
            comp.addlistener("Limits", "PostSet", @comp.limitsValueChanged);
        end

        function startTime = get.StartTime(comp)
            startTime = mag.app.internal.combineDateAndTime(comp.StartDatePicker.Value, comp.StartTimeField.Value);
        end

        function endTime = get.EndTime(comp)
            endTime = mag.app.internal.combineDateAndTime(comp.EndDatePicker.Value, comp.EndTimeField.Value);
        end

        function reset(comp)

            comp.Slider.Value = comp.SliderLimits;
            comp.updateSliderRange();
        end
    end

    methods (Hidden, Access = private)

        function limitsValueChanged(comp, ~, ~)

            comp.StartDatePicker.Limits = comp.Limits;
            comp.EndDatePicker.Limits = comp.Limits;

            comp.updateSliderRange();
        end

        function success = startDatePickerValueChanged(comp, ~, event)
            success = comp.setAndValidateDateValue(comp.StartTime, 1, "Start", event);
        end

        function success = endDatePickerValueChanged(comp, ~, event)
            success = comp.setAndValidateDateValue(comp.EndTime, 2, "End", event);
        end

        function startTimeEditFieldValueChanged(comp, ~, event)

            success = true;

            % Check that start time string can be converted to time.
            try
                comp.StartTime;
            catch exception

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), exception.message, "Cannot Set Start Time");
                success = false;
            end

            if success
                success = comp.startDatePickerValueChanged([], []);
            end

            if ~success
                comp.StartTimeField.Value = event.PreviousValue;
            end
        end

        function endTimeEditFieldValueChanged(comp, ~, event)

            success = true;

            % Check that end time string can be converted to time.
            try
                comp.EndTime;
            catch exception

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), exception.message, "Cannot Set End Time");
                success = false;
            end

            if success
                success = comp.endDatePickerValueChanged([], []);
            end

            if ~success
                comp.EndTimeField.Value = event.PreviousValue;
            end
        end

        function sliderValueChanging(comp, ~, event)

            value = event.Value;

            sliderRange = range(comp.Slider.Limits);
            dateRange = range(comp.Limits);

            % Set start datetime.
            startDate = dateRange * (value(1) / sliderRange) + comp.Limits(1);

            comp.StartDatePicker.Value = dateshift(startDate, "start", "day");
            comp.StartTimeField.Value = string(startDate, "HH:mm:ss.SSS");

            % Set end datetime.
            endDate = dateRange * (value(2) / sliderRange) + comp.Limits(1);

            comp.EndDatePicker.Value = dateshift(endDate, "start", "day");
            comp.EndTimeField.Value = string(endDate, "HH:mm:ss.SSS");
        end
    end

    methods (Access = private)

        function success = setAndValidateDateValue(comp, value, index, name, event)

            arguments
                comp
                value (1, 1) datetime
                index (1, 1) double {mustBeMember(index, [1, 2])}
                name (1, 1) string {mustBeMember(name, ["Start", "End"])}
                event
            end

            success = true;

            sliderRange = range(comp.Slider.Limits);
            dateRange = range(comp.Limits);

            errorTitle = compose("Cannot Set %s Date", name);
            otherName = setdiff(["start", "end"], lower(name));

            if value < comp.Limits(1)

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), compose("%s date must be greater than earliest date.", name), errorTitle);
                success = false;
            elseif value > comp.Limits(2)

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), compose("%s date must be less than latest date.", name), errorTitle);
                success = false;
            else

                try
                    comp.Slider.Value(index) = sliderRange * ((value - comp.Limits(1)) / dateRange) + comp.Slider.Limits(1);
                catch

                    uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), compose("%s date must be less than %s date.", name, otherName), errorTitle);
                    success = false;
                end
            end

            if ~success && ~isempty(event)
                comp.(name + "DatePicker").Value = event.PreviousValue;
            end
        end

        function updateSliderRange(comp)

            comp.StartDatePicker.Value = dateshift(comp.Limits(1), "start", "day");
            comp.StartTimeField.Value = string(comp.Limits(1), "HH:mm:ss.SSS");
            comp.EndDatePicker.Value = dateshift(comp.Limits(2), "start", "day");
            comp.EndTimeField.Value = string(comp.Limits(2), "HH:mm:ss.SSS");

            comp.Slider.Limits = comp.SliderLimits;
            comp.Slider.MajorTicks = 0:20:100;
            comp.Slider.MinorTicks = 0:2.5:100;

            N = numel(comp.Slider.MajorTicks);
            ticks = linspace(comp.Limits(1), comp.Limits(2), N);

            if range(comp.Limits) > days(7)
                comp.Slider.MajorTickLabels = string(ticks, "dd-MM-yy");
            else
                comp.Slider.MajorTickLabels = smartDatetimeString(ticks);
            end
        end
    end

    methods (Access = protected)

        function update(~)
            % nothing to do
        end

        function setup(comp)

            comp.Position = [1, 1, 650, 130];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = ["fit", "fit", "1.1x", "0.9x", "fit", "fit", "1.1x", "0.9x", "fit"];
            comp.GridLayout.RowHeight = ["fit", "1x", "1x", "fit"];

            % Create StartDatePicker
            startDatePickerLabel = uilabel(comp.GridLayout);
            startDatePickerLabel.HorizontalAlignment = "right";
            startDatePickerLabel.Layout.Row = 2;
            startDatePickerLabel.Layout.Column = 2;
            startDatePickerLabel.Text = "Start:";

            comp.StartDatePicker = uidatepicker(comp.GridLayout);
            comp.StartDatePicker.Layout.Row = 2;
            comp.StartDatePicker.Layout.Column = 3;
            comp.StartDatePicker.Limits = comp.Limits;
            comp.StartDatePicker.ValueChangedFcn = @comp.startDatePickerValueChanged;

            % Create EndDatePicker
            endDatePickerLabel = uilabel(comp.GridLayout);
            endDatePickerLabel.HorizontalAlignment = "right";
            endDatePickerLabel.Layout.Row = 2;
            endDatePickerLabel.Layout.Column = 6;
            endDatePickerLabel.Text = "End:";

            comp.EndDatePicker = uidatepicker(comp.GridLayout);
            comp.EndDatePicker.Layout.Row = 2;
            comp.EndDatePicker.Layout.Column = 7;
            comp.EndDatePicker.Limits = comp.Limits;
            comp.EndDatePicker.ValueChangedFcn = @comp.endDatePickerValueChanged;

            % Create StartTimeField
            comp.StartTimeField = uieditfield(comp.GridLayout, "text");
            comp.StartTimeField.Placeholder = "HH:mm:ss.SSS";
            comp.StartTimeField.Layout.Row = 2;
            comp.StartTimeField.Layout.Column = 4;
            comp.StartTimeField.ValueChangedFcn = @comp.startTimeEditFieldValueChanged;

            % Create EndTimeField
            comp.EndTimeField = uieditfield(comp.GridLayout, "text");
            comp.EndTimeField.Placeholder = "HH:mm:ss.SSS";
            comp.EndTimeField.Layout.Row = 2;
            comp.EndTimeField.Layout.Column = 8;
            comp.EndTimeField.ValueChangedFcn = @comp.endTimeEditFieldValueChanged;

            % Create Slider
            comp.Slider = uislider(comp.GridLayout, "range");
            comp.Slider.ValueChangingFcn = @comp.sliderValueChanging;
            comp.Slider.Layout.Row = 3;
            comp.Slider.Layout.Column = [2, 8];

            comp.updateSliderRange();
        end
    end
end
