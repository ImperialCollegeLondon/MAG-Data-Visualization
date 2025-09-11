classdef Line < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport
% LINE Definition of chart of "xline" or "yline" type.

    properties
        % AXIS Axis along which to plot.
        Axis (1, 1) string {mustBeMember(Axis, ["x", "y"])} = "y"
        % VALUE Line value.
        Value (1, :)
        % STYLE Line style.
        Style (1, 1) string = "-"
        % LABEL Line label.
        Label (1, :) string = string.empty()
        % HORIZONTALALIGNMENT Horizontal alignment of label.
        HorizontalAlignment (1, 1) string {mustBeMember(HorizontalAlignment, ["left", "center", "right"])} = "right"
        % VERTICALALIGNMENT Vertical alignment of label.
        VerticalAlignment (1, 1) string {mustBeMember(VerticalAlignment, ["top", "middle", "bottom"])} = "top"
    end

    methods

        function this = Line(options)

            arguments
                options.?mag.graphics.chart.Line
            end

            this.assignProperties(options);
        end

        function graph = plot(this, ~, axes, ~)

            arguments (Input)
                this (1, 1) mag.graphics.chart.Line
                ~
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            args = {axes, this.Value, this.Style, this.Label, ...
                "LabelHorizontalAlignment", this.HorizontalAlignment, "LabelVerticalAlignment", this.VerticalAlignment};

            switch this.Axis
                case "x"
                    graph = xline(args{:});
                case "y"
                    graph = yline(args{:});
            end

            this.applyColorStyle(graph);
        end
    end
end
