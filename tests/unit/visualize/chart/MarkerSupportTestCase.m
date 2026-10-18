classdef (Abstract, TestTags = ["Unit", "Parallel"]) MarkerSupportTestCase < MAGChartTestCase
% MARKERSUPPORTTESTCASE Base class for all charts that support markers.

    properties (TestParameter)
        MarkerProperties = {struct(Name = "Marker", Value = 'none'), ...
            struct(Name = "Marker", Value = 'o'), ...
            struct(Name = "MarkerSize", Value = 10), ...
            struct(Name = "MarkerColor", Value = "g", VerifiableName = "MarkerFaceColor", VerifiableValue = [0, 1, 0]), ...
            struct(Name = "MarkerColor", Value = "#FF0000", VerifiableName = "MarkerFaceColor", VerifiableValue = [1, 0, 0]), ...
            struct(Name = "MarkerColor", Value = [], VerifiableName = "MarkerEdgeColor", VerifiableValue = 'auto')}
    end

    methods (Test)

        function setMarkerProperty(testCase, MarkerProperties)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            args = testCase.getExtraArguments();

            % Exercise.
            chart = feval(testCase.ClassName, ...
                args{:}, ...
                MarkerProperties.Name, MarkerProperties.Value);

            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            graph = mag.test.GraphicsTestUtilities.getChildrenGraph(testCase, tl, ax, testCase.GraphClassName);

            testCase.verifySameHandle(assembledGraph, graph, "Chart should return assembled graph.");

            [verifiableName, verifiableValue] = mag.test.GraphicsTestUtilities.getVerifiables(MarkerProperties);
            testCase.verifyEqual(graph.(verifiableName), verifiableValue, compose("""%s"" property value should match.", MarkerProperties.Name));
        end
    end
end
