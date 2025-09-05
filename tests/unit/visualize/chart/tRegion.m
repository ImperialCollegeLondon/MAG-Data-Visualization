classdef tRegion < PropertiesTestCase & ColorSupportTestCase
% TREGION Unit tests for "mag.graphics.chart.Region" class.

    properties (Constant)
        ClassName = "mag.graphics.chart.Region"
        GraphClassName = "matlab.graphics.chart.decoration.ConstantRegion"
    end

    properties (TestParameter)
        Properties = {struct(Name = "Axis", Value = 'x', VerifiableName = "InterceptAxis"), ...
            struct(Name = "Axis", Value = 'y', VerifiableName = "InterceptAxis"), ...
            struct(Name = "Values", Value = [-1, 0], VerifiableName = "Value"), ...
            struct(Name = "Values", Value = [0, 0], VerifiableName = "Value"), ...
            struct(Name = "Values", Value = [0, 1], VerifiableName = "Value"), ...
            struct(Name = "Label", Value = 'Ciao', VerifiableName = "DisplayName"), ...
            struct(Name = "Label", Value = '你好', VerifiableName = "DisplayName")}
    end

    methods (Test)

        function showMultipleRegions(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            args = testCase.getExtraArguments();
            regions = [0, 1; 1, 2; 3, 4];

            % Exercise.
            chart = mag.graphics.chart.Region(args{:}, Values = regions);

            assembledGraph = chart.plot(testCase.Data, ax, tl);

            % Verify.
            testCase.assertSize(assembledGraph, [1, 3], "Chart should return all assembled graphs.");

            testCase.verifyEqual(vertcat(assembledGraph.Value), regions, """Value"" property value should match.");
        end
    end

    methods (Access = protected)

        function args = getExtraArguments(this)
            args = [getExtraArguments@MAGChartTestCase(this), {"Value"}, [0, 0]];
        end
    end

    methods (Static, Access = protected)

        function name = getColorPropertyName()
            name = "FaceColor";
        end
    end
end
