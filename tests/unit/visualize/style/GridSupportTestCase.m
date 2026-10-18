classdef (Abstract, TestTags = ["Unit", "Parallel"]) GridSupportTestCase < MAGStyleTestCase
% GRIDSUPPORTTESTCASE Base class for all styles that support grids.

    properties (TestParameter)
        GridProperties = {struct(Name = "Grid", Value = true, VerifiableName = "XGrid", VerifiableValue = matlab.lang.OnOffSwitchState.on), ...
            struct(Name = "Grid", Value = false, VerifiableName = "XGrid", VerifiableValue = matlab.lang.OnOffSwitchState.off)}
    end

    methods (Test)

        function setGridProperty(testCase, GridProperties)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            args = testCase.getExtraArguments();

            % Exercise.
            style = feval(testCase.ClassName, ...
                args{:}, ...
                GridProperties.Name, GridProperties.Value);

            axes = style.assemble(tl, ax, []);

            % Verify.
            [verifiableName, verifiableValue] = mag.test.GraphicsTestUtilities.getVerifiables(GridProperties);
            actualValue = axes.(verifiableName);

            if isa(actualValue, "matlab.graphics.primitive.Text")
                actualValue = actualValue.String;
            end

            testCase.verifyEqual(actualValue, verifiableValue, compose("""%s"" property value should match.", GridProperties.Name));
        end
    end
end
