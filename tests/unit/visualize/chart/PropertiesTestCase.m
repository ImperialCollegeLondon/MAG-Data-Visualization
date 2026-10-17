classdef (Abstract, TestTags = ["Unit", "Parallel"]) PropertiesTestCase < MAGChartTestCase
% PROPERTIESTESTCASE Base class for all charts that support extra
% properties.

    properties (Abstract, TestParameter)
        Properties (1, :) cell
    end

    methods (Test)

        function setSimpleProperty(testCase, Properties)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            args = testCase.getExtraArguments();

            % Exercise.
            chart = feval(testCase.ClassName, ...
                args{:}, ...
                Properties.Name, Properties.Value);

            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            graph = mag.test.GraphicsTestUtilities.getChildrenGraph(testCase, tl, ax, testCase.GraphClassName);

            testCase.verifySameHandle(assembledGraph, graph, "Chart should return assembled graph.");

            [verifiableName, verifiableValue] = mag.test.GraphicsTestUtilities.getVerifiables(Properties);
            testCase.verifyEqual(graph.(verifiableName), verifiableValue, compose("""%s"" property value should match.", Properties.Name));
        end
    end
end
