classdef (Abstract) Axes < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% AXES Style options for decoration of figure axes.

    properties
        % XLABEL Display name of x-axis.
        XLabel string {mustBeScalarOrEmpty} = string.empty()
        % XLIMITS Limits of x-axis.
        XLimits {mustBeA(XLimits, ["string", "double"]), mustBeVector(XLimits)} = "tight"
        % YLIMITS Limits of y-axis.
        YLimits {mustBeA(YLimits, ["string", "double"])} = "padded"
        % LAYOUT Array describing the size of the plot on the
        % "tiledlayout".
        Layout (1, 2) double = [1, 1]
        % TITLE Name of the plot.
        Title string {mustBeScalarOrEmpty}
        % CHARTS Charts to visualize on axes.
        Charts (1, :) mag.graphics.chart.Chart
    end

    methods

        function axes = assemble(this, layout, axes, data)
        % ASSEMBLE Assemble axes with selected charts and style.

            graph = matlab.graphics.Graphics.empty();

            if numel(this.Charts) > 1

                hold(axes, "on");
                resetAxesHold = onCleanup(@() hold(axes, "off"));
            end

            for c = this.Charts

                g = c.plot(data, axes, layout);
                graph = horzcat(graph, g); %#ok<AGROW>
            end

            axes = this.applyStyle(axes, graph);
        end
    end

    methods (Abstract, Access = protected)

        % APPLYSTYLE Apply style described by object to axes and/or graph.
        axes = applyStyle(this, axes, graph)
    end
end
