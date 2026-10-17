classdef (Abstract, TestTags = ["Unit", "Parallel"]) ColorSupportTestCase < MAGChartTestCase
% COLORSUPPORTTESTCASE Base class for all charts that support colors.

    properties (TestParameter)
        ColorProperties = {struct(Name = "Color", Value = 'g', VerifiableValue = [0, 1, 0]), ...
            struct(Name = "Color", Value = [1, 0, 1], VerifiableValue = [1, 0, 1]), ...
            struct(Name = "Color", Value = "#FFFF00", VerifiableValue = [1, 1, 0])}
    end

    methods (Test)

        function setColorProperty(testCase, ColorProperties)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            args = testCase.getExtraArguments();

            % Exercise.
            chart = feval(testCase.ClassName, ...
                args{:}, ...
                ColorProperties.Name, ColorProperties.Value);

            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            graph = mag.test.GraphicsTestUtilities.getChildrenGraph(testCase, tl, ax, testCase.GraphClassName);

            testCase.verifySameHandle(assembledGraph, graph, "Chart should return assembled graph.");

            [~, verifiableValue] = mag.test.GraphicsTestUtilities.getVerifiables(ColorProperties);
            testCase.verifyEqual(graph.(testCase.getColorPropertyName()), verifiableValue, compose("""%s"" property value should match.", ColorProperties.Name));
        end
    end

    methods (Static, Access = protected)

        function name = getColorPropertyName()
        % GETCOLORPROPERTYNAME Retrieve name of property defining color.
        % Can be overridden by subclasses for customization.

            name = "Color";
        end
    end
end
