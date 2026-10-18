classdef (TestTags = ["Unit", "Parallel"]) tStem < PropertiesTestCase & ColorSupportTestCase & MarkerSupportTestCase
% TSTEM Unit tests for "mag.graphics.chart.Stem" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Stem"
        GraphClassName = "matlab.graphics.chart.primitive.Stem"
    end

    properties (TestParameter)
        Properties = {struct(Name = "LineStyle", Value = '-'), ...
            struct(Name = "LineStyle", Value = '--')}
    end
end
