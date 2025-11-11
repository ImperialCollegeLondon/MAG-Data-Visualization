classdef tPlot < PropertiesTestCase & ColorSupportTestCase & MarkerSupportTestCase
% TPLOT Unit tests for "mag.graphics.chart.Plot" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Plot"
        GraphClassName = "matlab.graphics.chart.primitive.Line"
    end

    properties (TestParameter)
        Properties = {struct(Name = "LineStyle", Value = '-'), ...
            struct(Name = "LineStyle", Value = '--')}
    end

    methods (Test)

        function plotWithMultipleLines_sameVariables(testCase)

            % Set up.
            data1 = testCase.Data;

            data2 = data1;
            data2.Number = data2.Number + 10;

            % Exercise.
            f = mag.graphics.visualize({data1, data2}, mag.graphics.style.Default(Charts = mag.graphics.chart.Plot(YVariables = "Number")));
            testCase.addTeardown(@() close(f));

            % Verify.
            % The chart should only return the main objects, but the figure
            % should also show two vertical lines per plot.
            testCase.assertTrue(isvalid(f), "Figure should be valid.");

            axes = mag.test.getAllAxes(f);
            testCase.assertClass(axes, "matlab.graphics.axis.Axes", "Child should be a tiled layout.");

            graph = [axes.Children];

            testCase.assertSize(graph, [2, 1], "Number of graphs should match expectation.");
            testCase.assertClass(graph, "matlab.graphics.chart.primitive.Line", "Graphs should be lines.");

            testCase.verifyEqual(graph(1).YData, data2.Number', "Graph data should match.");
            testCase.verifyEqual(graph(2).YData, data1.Number', "Graph data should match.");
        end
    end
end
