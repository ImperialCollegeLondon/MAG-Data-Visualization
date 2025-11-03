classdef Function < mag.graphics.chart.Chart & mag.graphics.mixin.ColorSupport & mag.graphics.mixin.LineSupport & mag.graphics.mixin.MarkerSupport
% FUNCTION Definition of chart of "fplot" type.

    properties
        % CALLABLE Function handle to plot.
        Callable (1, 1) function_handle = @(x) x
        % RESOLUTION Number of mesh points for generated plot.
        Resolution (1, 1) double = 100
    end

    methods

        function this = Function(options)

            arguments
                options.?mag.graphics.chart.Function
            end

            this.assignProperties(options);
        end

        function graph = plot(this, ~, axes, ~)

            arguments (Input)
                this (1, 1) mag.graphics.chart.Function
                ~
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            graph = fplot(axes, this.Callable, MeshDensity = this.Resolution);

            this.applyColorStyle(graph);
            this.applyLineCustomization(graph);
            this.applyMarkerStyle(graph);
        end
    end
end
