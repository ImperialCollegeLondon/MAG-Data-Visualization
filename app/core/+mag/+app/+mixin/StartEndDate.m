classdef (Abstract, HandleCompatible) StartEndDate
% STARTENDDATE Add support for start and end date selection.

    properties (SetAccess = protected)
        Slider mag.app.component.DatetimeRangeSlider
    end

    methods (Access = protected)

        function addStartEndDateButtons(this, parent, options)

            arguments
                this
                parent (1, 1) matlab.ui.container.GridLayout
                options.Rows (1, 2) double = [1, 2]
                options.Columns (1, 2) double = [1, 3]
                options.Limits (1, 2) datetime = [NaT(), NaT()]
            end

            this.Slider = mag.app.component.DatetimeRangeSlider(parent);
            this.Slider.Layout.Row = options.Rows;
            this.Slider.Layout.Column = options.Columns;

            if ~any(isnat(options.Limits))
                this.changeSliderLimits(options.Limits);
            end
        end

        function changeSliderLimits(this, limits, options)

            arguments
                this (1, 1) mag.app.mixin.StartEndDate
                limits (1, 2) datetime
                options.IncludeBuffer (1, 1) logical = false
            end

            if options.IncludeBuffer
                limits = limits + [-hours(1), hours(1)];
            end

            this.Slider.Limits = limits;
        end

        function [startTime, endTime] = getStartEndTimes(this)

            startTime = this.Slider.StartTime;
            endTime = this.Slider.EndTime;
        end

        function resetStartEndDate(this)
            this.Slider.reset();
        end
    end
end
