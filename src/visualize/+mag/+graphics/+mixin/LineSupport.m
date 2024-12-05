classdef (Abstract, HandleCompatible) LineSupport
% LINESUPPORT Add support for line customization for a chart.

    properties
        % LINESTYLE Line style.
        LineStyle (1, 1) string = "-"
        % LINEWIDTH Line size.
        LineWidth (1, 1) double = 0.5
    end

    properties (Dependent, Access = protected)
        % LINECUSTOMIZATION Line customization to apply to graph
        % constructor.
        LineCustomization (1, :) cell
    end

    methods

        function customization = get.LineCustomization(this)

            customization = {"LineStyle", this.LineStyle, ...
                "LineWidth", this.LineWidth};
        end
    end

    methods (Access = protected)

        function applyLineCustomization(this, graph)
        % APPLYLINECUSTOMIZATION Apply specified line customization to a
        % graph.

            for i = 1:numel(graph)

                set(graph(i), ...
                    LineStyle = this.LineStyle, ...
                    LineWidth = this.LineWidth);
            end
        end
    end
end
