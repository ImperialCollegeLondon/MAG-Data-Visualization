classdef Plot < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.MarkerSupport
% PLOT Definition of chart of "plot" type.

    properties
        % LINESTYLE Line style.
        LineStyle (1, 1) string = "-"
    end

    methods

        function this = Plot(options)

            arguments
                options.?mag.graphics.chart.Plot
                options.MarkerSize (1, 1) double = 6
            end

            this.assignProperties(options);
        end

        function value = isSupported(this, data)

            % Also support cell arrays, but do not allow cells of cells.
            value = isSupported@mag.graphics.chart.Chart(this, data) || ...
                (~isempty(data) && iscell(data) && ~any(cellfun(@iscell, data)) && all(cellfun(@(x) this.isSupported(x), data)));
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this
                data {mustBeA(data, ["mag.Data", "tabular", "cell"])}
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            if ~iscell(data)
                data = {data};
            end

            xData = cellfun(@(x) this.getXData(x), data, UniformOutput = false);
            yData = cellfun(@(x) this.getYData(x), data, UniformOutput = false);

            hold(axes, "on");
            resetAxesHold = onCleanup(@() hold(axes, "off"));

            graph = matlab.graphics.chart.primitive.Line.empty();

            for i = 1:numel(xData)

                g = plot(axes, xData{i}, yData{i}, this.MarkerStyle{:}, LineStyle = this.LineStyle);
                graph = [graph; g]; %#ok<AGROW>
            end

            this.applyColorStyle(graph);
        end
    end
end
