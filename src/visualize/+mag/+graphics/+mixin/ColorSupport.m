classdef (Abstract, HandleCompatible) ColorSupport
% COLORSUPPORT Add support for color customization for a chart.

    properties
        % COLORS Colors used for different lines in same plot.
        Colors {mag.graphics.mixin.mustBeColor} = double.empty(0, 3)
    end

    methods (Access = protected)

        function applyColorStyle(this, graph, colorOptionName)
        % APPLYCOLORSTYLE Set color of graph based on selected colors.
        % Error checking is done to make sure enough colors are available
        % for each graph.

            arguments
                this
                graph (1, :) matlab.graphics.Graphics
                colorOptionName (1, 1) string = "Color"
            end

            if (numel(graph) <= size(this.Colors, 1))

                for i = 1:numel(graph)
                    set(graph(i), colorOptionName, this.Colors(i, :));
                end
            elseif ~isempty(this.Colors) && (numel(graph) > size(this.Colors, 1))
                error("mag:graphics:ColorNumberMismatch", "Mismatch in number of colors for number of plots.");
            end
        end
    end
end
