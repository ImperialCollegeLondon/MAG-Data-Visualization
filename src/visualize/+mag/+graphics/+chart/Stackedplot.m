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

        function value = isSupported(this, data)

            % Also support cell arrays, but do not allow cells of cells.
            value = isSupported@mag.graphics.chart.Chart(this, data) || ...
                (~isempty(data) && iscell(data) && ~any(cellfun(@iscell, data)) && all(cellfun(@(x) this.isSupported(x), data)));
        end

        function graph = plot(this, data, axes, layout)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "timetable", "cell"])}
                axes (1, 1) matlab.graphics.axis.Axes
                layout (1, 1) matlab.graphics.layout.TiledChartLayout
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            if ~iscell(data)
                data = {data};
            end

            xData = cellfun(@(x) this.getXData(x), data, UniformOutput = false);
            yData = cellfun(@(x) this.getYData(x), data, UniformOutput = false);

            Ny = width(yData{1});
            Nz = numel(data);

            if height(this.Colors) == 1
                colors = repmat(this.Colors, Ny, 1);
            elseif isempty(this.Colors) || (Ny > height(this.Colors))
                error("mag:graphics:ColorNumberMismatch", "Mismatch in number of colors for number of plots.");
            else
                colors = this.Colors;
            end

            % Check if layout already has a stack layout.
            existingGraphics = layout.Children;

            if isempty(existingGraphics) || ~isequal(existingGraphics(1).Type, "tiledlayout")
                stackLayout = tiledlayout(layout, Ny, 1, TileSpacing = "tight", Padding = "tight", Layout = axes.Layout);
            else
                stackLayout = existingGraphics(1);
            end

            % Create custom stacked plot.
            graph = matlab.graphics.chart.primitive.Line.empty();

            for y = 1:Ny

                ax = nexttile(stackLayout, y);

                hold(ax, "on");
                resetAxesHold = onCleanup(@() hold(ax, "off"));

                g = matlab.graphics.chart.primitive.Line.empty(0, Nz);

                for z = 1:Nz

                    % If only 1 line per axis, the color changes per tile,
                    % otherwise it changes per line.
                    if Nz == 1
                        c = y;
                    else
                        c = z;
                    end

                    g(z) = plot(ax, xData{z}, yData{z}(:, y), this.MarkerStyle{:}, this.LineCustomization{:}, Color = colors(c, :));
                end

                graph = [graph, g]; %#ok<AGROW>

                if this.EventsVisible
                    this.addEventsData(ax, data);
                end
            end
        end
    end

    methods (Static, Access = private)

        function addEventsData(ax, data)

            if iscell(data) && isscalar(data)
                data = data{1};
            end

            if isa(data, "mag.TimeSeries")
                events = data.Events;
            elseif istimetable(data)
                events = data.Properties.Events;
            else
                events = [];
            end

            if isempty(events)
                return;
            end

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
