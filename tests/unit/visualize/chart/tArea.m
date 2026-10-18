classdef (TestTags = ["Unit", "Parallel"]) tArea < ColorSupportTestCase
% TAREA Unit tests for "mag.graphics.chart.Area" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Area"
        GraphClassName = "matlab.graphics.chart.primitive.Area"
    end

    methods (Static, Access = protected)

        function name = getColorPropertyName()
            name = "FaceColor";
        end
    end
end
