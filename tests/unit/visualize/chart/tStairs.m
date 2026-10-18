classdef (TestTags = ["Unit", "Parallel"]) tStairs < PropertiesTestCase & ColorSupportTestCase & MarkerSupportTestCase
% TSTAIRS Unit tests for "mag.graphics.chart.Stairs" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Stairs"
        GraphClassName = "matlab.graphics.chart.primitive.Stair"
    end

    properties (TestParameter)
        Properties = {struct(Name = "LineStyle", Value = '-'), ...
            struct(Name = "LineStyle", Value = '--')}
    end
end
