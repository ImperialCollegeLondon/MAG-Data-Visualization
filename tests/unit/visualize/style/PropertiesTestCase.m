classdef (Abstract, TestTags = ["Unit", "Parallel"]) PropertiesTestCase < MAGStyleTestCase
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
            style = feval(testCase.ClassName, ...
                args{:}, ...
                Properties.Name, Properties.Value);

            axes = style.assemble(tl, ax, []);

            % Verify.
            [verifiableName, verifiableValue] = mag.test.GraphicsTestUtilities.getVerifiables(Properties);
            actualValue = axes.(verifiableName);

            if isa(actualValue, "matlab.graphics.primitive.Text")
                actualValue = actualValue.String;
            end

            testCase.verifyEqual(actualValue, verifiableValue, compose("""%s"" property value should match.", Properties.Name));
        end
    end
end
