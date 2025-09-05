classdef Event < mag.graphics.chart.Chart
% EVENT Custom chart for plotting IMAP events.

    properties
        % EVENTOFINTEREST Event name to plot.
        EventOfInterest (1, 1) string
        % ENDTIME Final event end time.
        EndTime datetime {mustBeScalarOrEmpty} = datetime.empty()
        % YOFFSET Offset of label describing y-axis value.
        YOffset (1, 1) double = 1
        % IGNOREMISSING Ignore missing values.
        IgnoreMissing (1, 1) logical = true
        % COMBINEEVENETS Combine events with equal values.
        CombineEvents (1, 1) logical = true
    end

    methods

        function this = Event(options)

            arguments
                options.?mag.imap.chart.Event
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this (1, 1) mag.imap.chart.Event
                data {mustBeA(data, ["mag.Science", "timetable"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            graph = matlab.graphics.Graphics.empty();

            if isa(data, "mag.Science")

                eventOfInterest = data.Settings.(this.EventOfInterest);
                data = data.Data;
            else
                eventOfInterest = this.EventOfInterest;
            end

            hold(axes, "on");
            resetAxesHold = onCleanup(@() hold(axes, "off"));

            % Process data.
            if this.IgnoreMissing
                interestingEvents = data(~ismissing(data.(eventOfInterest)), :);
            else
                interestingEvents = data;
            end

            if this.CombineEvents

                locCombine = [false; diff(interestingEvents.(eventOfInterest)) == 0];
                interestingEvents(locCombine, :) = [];
            end

            if isempty(this.EndTime)
                endTime = data.(data.Properties.DimensionNames{1})(end);
            else
                endTime = this.EndTime;
            end

            time = interestingEvents.(interestingEvents.Properties.DimensionNames{1});
            variable = interestingEvents.(eventOfInterest);

            if isenum(variable) && isnumeric(variable)
                variable = double(variable);
            elseif ~isnumeric(variable)
                variable = categorical(variable);
            end

            plotTime = repmat(datetime("now", TimeZone = "UTC"), 2 * numel(time), 1);
            plotTime(1:2:end) = time;
            plotTime(2:2:end) = [time(2:end); endTime];
            plotTime = reshape(plotTime, 2, []);

            plotVariable = [variable, variable]';

            % Plot lines.
            plotColors = this.getColors(variable);

            for i = 1:numel(variable)
                graph(i) = plot(axes, plotTime(:, i), plotVariable(:, i), Color = plotColors(i, :), LineWidth = 3.5);
            end

            % Plot vertical lines between mode changes.
            xline(axes, [time; endTime], "--");

            % Plot text annotation.
            if ~iscategorical(variable)

                for i = 1:numel(variable)
                    text(axes, mean(graph(i).XData), this.YOffset + variable(i), string(variable(i)), HorizontalAlignment = "center", VerticalAlignment = "bottom");
                end
            end

            % Plot ramp mode.
            locMissing = ismissing(variable);

            if any(locMissing)

                v = 0.5;
                t = "Ramp";

                for i = find(locMissing')
                    text(axes, mean(graph(i).XData), v, t, HorizontalAlignment = "center", VerticalAlignment = "middle", Rotation = 90);
                end
            end

            % Fit axes to include text.
            txt = findobj(axes, Type = "Text");

            if isempty(txt)
                return;
            elseif isscalar(txt)
                extents = get(txt, "Extent");
            else
                extents = cell2mat(get(txt, "Extent"));
            end

            upperPosition = sum(extents(:, [2, 4]), 2);
            ylim(axes, [min(ylim(axes)), max(max(ylim(axes)), max(upperPosition))]);
        end
    end

    methods (Static, Access = private)

        function colors = getColors(variable)

            defaultColors = colororder();
            [~, ~, idxUnique] = unique(variable);

            colors = zeros(numel(variable), 3);

            for i = 1:numel(idxUnique)
                colors(i, :) = defaultColors(idxUnique(i), :);
            end
        end
    end
end
