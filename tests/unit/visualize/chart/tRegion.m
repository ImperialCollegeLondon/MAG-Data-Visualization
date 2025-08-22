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
