classdef (Abstract) MarkerSupportTestCase < MAGVisualizationTestCase
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
            ax = GraphicsTestUtilities.createAxes(testCase);

            % Exercise.
            chart = feval(testCase.ClassName, ...
                MarkerProperties.Name, MarkerProperties.Value, ...
                YVariables = "Var1");

            chart.plot(testCase.Data, ax, []);

            % Verify.
            graph = GraphicsTestUtilities.getChildrenGraph(testCase, ax, testCase.GraphClassName);

            [verifiableName, verifiableValue] = GraphicsTestUtilities.getVerifiables(MarkerProperties);
            testCase.verifyEqual(graph.(verifiableName), verifiableValue, compose("""%s"" property value should match.", MarkerProperties.Name));
        end
    end
end
