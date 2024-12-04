classdef Stackedplot < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport & mag.graphics.mixin.LineSupport
% STACKEDPLOT Definition of chart of "stackedplot" type.

    properties
        % EVENTSVISIBLE Display timetable events as vertical lines in the
        % plot.
        EventsVisible (1, 1) logical = false
    end

    methods

        function this = Stackedplot(options)

            arguments
                options.?mag.graphics.chart.Stackedplot
                options.Colors (:, 3) double = colororder()
                options.MarkerSize (1, 1) double = 6
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, layout)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "timetable"])}
                axes (1, 1) matlab.graphics.axis.Axes
                layout (1, 1) matlab.graphics.layout.TiledChartLayout
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            xData = this.getXData(data);
            yData = this.getYData(data);

            Ny = width(yData);

            if isempty(this.Colors) || (Ny > size(this.Colors, 1))
                error("Mismatch in number of colors for number of plots.");
            end

            % Create custom stacked plot.
            graph = matlab.graphics.chart.primitive.Line.empty(0, Ny);
            stackLayout = tiledlayout(layout, Ny, 1, TileSpacing = "tight", Padding = "tight", Layout = axes.Layout);

            for y = 1:Ny

                ax = nexttile(stackLayout);
                graph(y) = plot(ax, xData, yData(:, y), this.MarkerStyle{:}, this.LineCustomization{:}, Color = this.Colors(y, :));

                if this.EventsVisible && ~isempty(data.Properties.Events)
                    this.addEventsData(ax, data);
                end
            end
        end
    end

    methods (Static, Access = private)

        function addEventsData(ax, data)

            hold(ax, "on");
            resetAxesHold = onCleanup(@() hold(ax, "off"));

            events = data.Properties.Events;

            eventTimes = events.Properties.RowTimes;
            eventLabels = events.(events.Properties.EventLabelsVariable);

            if ~isempty(events.Properties.EventLengthsVariable)
                xregion(ax, eventTimes, eventTimes + events.(events.Properties.EventLengthsVariable));
            elseif ~isempty(events.Properties.EventEndsVariable)
                xregion(ax, eventTimes, events.(events.Properties.EventEndsVariable));
            end

            xline(ax, eventTimes, "-", eventLabels);
        end
    end
end
