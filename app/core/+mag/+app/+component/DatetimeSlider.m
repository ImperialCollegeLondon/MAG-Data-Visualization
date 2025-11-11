classdef DatetimeSlider < matlab.ui.componentcontainer.ComponentContainer
% DATETIMESLIDER Slider for selecting a datetime from a range.

    properties (SetAccess = private, Transient, NonCopyable)
        GridLayout matlab.ui.container.GridLayout
        Slider matlab.ui.control.Slider
        DatePicker matlab.ui.control.DatePicker
        TimeField matlab.ui.control.EditField
    end

    properties (Constant)
        % SLIDERLIMITS Range of slider values.
        SliderLimits (1, 2) double = [0, 100]
    end

    properties (AbortSet, SetObservable)
        % LIMITS Limits of slider.
        Limits (1, 2) datetime = [datetime("yesterday", TimeZone = "UTC"), datetime("tomorrow", TimeZone = "UTC")]
    end

    properties (Dependent)
        % TOOLTIP Tooltip to display on UI elements.
        Tooltip string {mustBeScalarOrEmpty}
        % SELECTEDTIME Selected datetime.
        SelectedTime (1, 1) datetime
    end

    properties (Access = private)
        % ORIGINALTIMEZONE Time zone of original input.
        OriginalTimeZone string {mustBeScalarOrEmpty}
    end

    methods

        function comp = DatetimeSlider(varargin)

            comp = comp@matlab.ui.componentcontainer.ComponentContainer(varargin{:});
            comp.addlistener("Limits", "PostSet", @comp.limitsValueChanged);

            comp.limitsValueChanged();
        end

        function set.Tooltip(comp, tooltip)

            arguments
                comp (1, 1) mag.app.component.DatetimeSlider
                tooltip (1, 1) string
            end

            comp.Slider.Tooltip = tooltip;
            comp.DatePicker.Tooltip = tooltip;
            comp.TimeField.Tooltip = tooltip;
        end

        function tooltip = get.Tooltip(comp)
            tooltip = comp.Slider.Tooltip;
        end

        function set.SelectedTime(comp, time)

            arguments
                comp (1, 1) mag.app.component.DatetimeSlider
                time (1, 1) datetime
            end

            previousTime = comp.SelectedTime;
            time.TimeZone = comp.OriginalTimeZone;

            try
                comp.setDateAndTime(time);
            catch e

                comp.setDateAndTime(previousTime);

                exception = MException("mag:app:component:InvalidSelectedTime", "Selected time ""%s"" is invalid.", string(time));
                exception = exception.addCause(e);

                exception.throw();
            end

            comp.datePickerValueChanged([], []);
        end

        function time = get.SelectedTime(comp)
            time = mag.app.internal.combineDateAndTime(comp.DatePicker.Value, comp.TimeField.Value, TimeZone = comp.OriginalTimeZone);
        end

        function reset(comp)

            comp.Slider.Value = comp.SliderLimits(1);
            comp.updateSliderRange();
        end
    end

    methods (Hidden, Access = private)

        function limitsValueChanged(comp, ~, ~)

            comp.DatePicker.Limits = comp.Limits;
            comp.OriginalTimeZone = comp.Limits.TimeZone;

            comp.updateSliderRange();
        end

        function success = datePickerValueChanged(comp, ~, event)

            success = true;
            value = comp.SelectedTime;

            sliderRange = range(comp.Slider.Limits);
            dateRange = range(comp.Limits);

            if value < comp.Limits(1)

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), "Date must be greater than earliest date.", "Cannot Set Date");
                success = false;
            elseif value > comp.Limits(2)

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), "Date must be less than latest date.", "Cannot Set Date");
                success = false;
            else

                try
                    comp.Slider.Value = sliderRange * ((value - comp.Limits(1)) / dateRange) + comp.Slider.Limits(1);
                catch exception

                    uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), exception.message, "Cannot Set Date");
                    success = false;
                end
            end

            if ~success && ~isempty(event)
                comp.DatePicker.Value = event.PreviousValue;
            end
        end

        function timeEditFieldValueChanged(comp, ~, event)

            success = true;

            % Check that time string can be converted to time.
            try
                comp.SelectedTime;
            catch exception

                uialert(ancestor(comp.GridLayout, "Figure", "toplevel"), exception.message, "Cannot Set Time");
                success = false;
            end

            if success
                success = comp.datePickerValueChanged([], []);
            end

            if ~success
                comp.TimeField.Value = event.PreviousValue;
            end
        end

        function sliderValueChanging(comp, ~, event)

            value = event.Value;

            sliderRange = range(comp.Slider.Limits);
            dateRange = range(comp.Limits);

            date = dateRange * (value(1) / sliderRange) + comp.Limits(1);
            comp.setDateAndTime(date);
        end
    end

    methods (Access = private)

        function updateSliderRange(comp)

            comp.setDateAndTime(comp.Limits(1));

            comp.Slider.Limits = comp.SliderLimits;
            comp.Slider.MajorTicks = 0:25:100;
            comp.Slider.MinorTicks = 0:2.5:100;

            N = numel(comp.Slider.MajorTicks);
            ticks = linspace(comp.Limits(1), comp.Limits(2), N);

            if range(comp.Limits) >= days(4)
                comp.Slider.MajorTickLabels = string(ticks, "dd-MM-yy");
            else
                comp.Slider.MajorTickLabels = smartDatetimeString(ticks);
            end
        end

        function setDateAndTime(comp, value)

            comp.DatePicker.Value = dateshift(value, "start", "day");
            comp.TimeField.Value = string(value, "HH:mm:ss.SSS");
        end
    end

    methods (Access = protected)

        function update(~)
            % nothing to do
        end

        function setup(comp)

            comp.Position = [1, 1, 650, 75];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.ColumnWidth = ["1x", "1x"];
            comp.GridLayout.RowHeight = ["1x", "1x"];

            % Create DatePicker
            comp.DatePicker = uidatepicker(comp.GridLayout);
            comp.DatePicker.Layout.Row = 1;
            comp.DatePicker.Layout.Column = 1;
            comp.DatePicker.Limits = comp.Limits;
            comp.DatePicker.ValueChangedFcn = @comp.datePickerValueChanged;

            % Create TimeField
            comp.TimeField = uieditfield(comp.GridLayout, "text");
            comp.TimeField.Placeholder = "HH:mm:ss.SSS";
            comp.TimeField.Layout.Row = 1;
            comp.TimeField.Layout.Column = 2;
            comp.TimeField.ValueChangedFcn = @comp.timeEditFieldValueChanged;

            % Create Slider
            comp.Slider = uislider(comp.GridLayout);
            comp.Slider.ValueChangingFcn = @comp.sliderValueChanging;
            comp.Slider.Layout.Row = 2;
            comp.Slider.Layout.Column = [1, 2];

            comp.updateSliderRange();
        end
    end
end
