classdef (TestTags = ["Unit", "Parallel"]) tScatter < PropertiesTestCase
% TSCATTER Unit tests for "mag.graphics.chart.Scatter" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Scatter"
        GraphClassName = "matlab.graphics.chart.primitive.Scatter"
    end

    properties (TestParameter)
        Properties = {struct(Name = "Marker", Value = 'none'), ...
            struct(Name = "Marker", Value = 'o'), ...
            struct(Name = "Marker", Value = '*'), ...
            struct(Name = "MarkerSize", Value = 10, VerifiableName = "SizeData"), ...
            struct(Name = "MarkerColor", Value = "g", VerifiableName = "MarkerFaceColor", VerifiableValue = [0, 1, 0]), ...
            struct(Name = "MarkerColor", Value = "g", VerifiableName = "MarkerEdgeColor", VerifiableValue = [0, 1, 0])}
    end
end
