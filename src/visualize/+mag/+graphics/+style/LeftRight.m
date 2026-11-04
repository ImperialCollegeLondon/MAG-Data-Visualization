classdef LeftRight < mag.graphics.style.Axes & mag.graphics.mixin.GridSupport & mag.graphics.mixin.LegendSupport
% LEFTRIGHT Style options for decoration of figure with left and right
% y-axis variables to plot.

    properties
        % LEFTLABELS Display name of left y-axes.
        LeftLabel (1, 1) string
        % RIGHTLABELS Display name of right y-axes.
        RightLabel (1, 1) string
        % YLIMITS Limits of left y-axis.
        LLimits {mustBeA(LLimits, ["string", "double"]), mustBeVector(LLimits)} = "padded"
        % YLIMITS Limits of right y-axis.
        RLimits {mustBeA(RLimits, ["string", "double"]), mustBeVector(RLimits)} = "padded"
    end

    methods

        function this = LeftRight(options)

            arguments
                options.?mag.graphics.style.LeftRight
                options.Charts (1, 2) mag.graphics.chart.Chart
            end

            if isfield(options, "YLimits")
                warning("mag:graphics:IgnoredYLimits", """YLimits"" option is ignored. Use ""LLimits"" and/or ""RLimits"" to specify left and right axis limits, respectively.");
            end

            this.set(options);
        end

        function axes = assemble(this, layout, axes, data)

            graph = matlab.graphics.Graphics.empty();

            yyaxis(axes, "left");
            graph(1) = this.Charts(1).plot(data, axes, layout);

            yyaxis(axes, "right");
            graph(2) = this.Charts(2).plot(data, axes, layout);

            axes = this.applyStyle(axes, graph);
        end
    end

    methods (Access = protected)

        function axes = applyStyle(this, axes, ~)

            arguments (Input)
                this
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                axes (1, :) matlab.graphics.axis.Axes
            end

            xlabel(axes, this.XLabel);
            xlim(axes, this.XLimits);

            yyaxis(axes, "left");
            ylabel(axes, this.LeftLabel);
            ylim(axes, this.LLimits);

            yyaxis(axes, "right");
            ylabel(axes, this.RightLabel);
            ylim(axes, this.RLimits);

            if ~isempty(this.Title)
                title(axes, this.Title);
            end

            this.applyGridStyle(axes);
            this.applyLegendStyle(axes);
        end
    end
end
