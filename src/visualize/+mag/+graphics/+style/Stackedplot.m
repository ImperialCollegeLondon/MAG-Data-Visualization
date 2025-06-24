classdef Stackedplot < mag.graphics.style.Axes & mag.graphics.mixin.GridSupport & mag.graphics.mixin.LegendSupport
% STACKEDPLOT Style options for decoration of figure with multiple y-axis
% variables to plot.

    properties
        % YLABELS Display names of y-axes.
        YLabels (1, :) string
        % YLIMITS Limits of y-axis.
        YAxisLocation (1, 1) string {mustBeMember(YAxisLocation, ["left", "right"])} = "left"
        % ROTATELABELS Rotate y-axes labels.
        RotateLabels (1, 1) logical = false
    end

    methods

        function this = Stackedplot(options)

            arguments
                options.?mag.graphics.style.Stackedplot
                options.Charts (1, :) mag.graphics.chart.Stackedplot
                options.LegendLocation (1, 1) string {mustBeMember(options.LegendLocation, ["north", "south", "east", "west"])} = "south"
            end

            this.set(options);
        end
    end

    methods (Access = protected)

        function axes = applyStyle(this, axes, graph)

            arguments (Input)
                this (1, 1) mag.graphics.style.Stackedplot
                axes (1, 1) matlab.graphics.axis.Axes
                graph (1, :) matlab.graphics.chart.primitive.Line
            end

            arguments (Output)
                axes (1, :) matlab.graphics.axis.Axes
            end

            % Disable parent axes and retrieve real ones.
            axes.Visible = "off";

            axes = [graph.Parent];
            linkaxes(axes, "x");

            % Set axes properties.
            xlabel(axes, this.XLabel);
            xlim(axes, this.XLimits);

            t = matlab.graphics.primitive.Text.empty(0, numel(axes));

            if ~isempty(this.YLabels)

                for i = 1:numel(this.YLabels)
                    t(i) = ylabel(axes(i), this.YLabels(i));
                end
            end

            if this.RotateLabels
                [t.Rotation] = deal(0);
            end

            ylim(axes, this.YLimits);
            set(axes, YAxisLocation = this.YAxisLocation);

            if ~isempty(this.Title)
                title(axes(1), this.Title);
            end

            this.applyGridStyle(axes);

            % Add legend.
            l = this.applyLegendStyle(axes(1));

            if ~isempty(l)
                l.Layout.Tile = this.LegendLocation;
            end

            % Prettify axes appearance to match built-in stackedplot.
            xAxes = [axes(1:end-1).XAxis];
            [xAxes.Visible] = deal("off");

            [axes.Box] = deal("off");
        end
    end
end
