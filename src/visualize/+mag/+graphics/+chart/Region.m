classdef Region < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport
% REGION Definition of chart of "xregion" or "yregion" type.

    properties
        % AXIS Axis along which to plot.
        Axis (1, 1) string {mustBeMember(Axis, ["x", "y"])} = "y"
        % VALUE Region value.
        Values (:, 2)
        % LABEL Region label.
        Label (1, :) string = string.empty()
    end

    methods

        function this = Region(options)

            arguments
                options.?mag.graphics.chart.Region
            end

            this.assignProperties(options);
        end

        function graph = plot(this, ~, axes, ~)

            arguments (Input)
                this (1, 1) mag.graphics.chart.Region
                ~
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            args = {axes, this.Values'};

            switch this.Axis
                case "x"
                    graph = xregion(args{:});
                case "y"
                    graph = yregion(args{:});
            end

            if ~isempty(this.Label)

                if isscalar(this.Label)
                    labels = repmat(this.Label, 1, numel(graph));
                else
                    labels = this.Label;
                end

                for i = 1:numel(graph)
                    set(graph(i), DisplayName = labels(i, :));
                end
            end

            this.applyColorStyle(graph, "FaceColor");
        end
    end
end
