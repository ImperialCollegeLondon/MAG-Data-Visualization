classdef (Abstract, TestTags = ["Unit", "Parallel"]) LegendSupportTestCase < MAGStyleTestCase
% LEGENDSUPPORTTESTCASE Base class for all styles that support legends.

    methods (Test)

        % Test that legend labels can be set.
        function setLegendLabel(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);
            args = testCase.getExtraArguments();

            labels = ["a", "b"];

            % Exercise.
            style = feval(testCase.ClassName, ...
                args{:}, ...
                Legend = labels);

            plot(ax, 0:9, 1:1:10, 0:9, 10:-1:1);
            axes = style.assemble(tl, ax, []);

            % Verify.
            testCase.verifyEqual(axes.Legend.String, cellstr(labels), """Legend"" property value should match.");
        end

        % Test that legend location can be set.
        function setLegendLocation(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);
            args = testCase.getExtraArguments();

            location = 'southwest';

            % Exercise.
            style = feval(testCase.ClassName, ...
                args{:}, ...
                Legend = ["a", "b"], ...
                LegendLocation = location);

            plot(ax, 0:9, 1:1:10, 0:9, 10:-1:1);
            axes = style.assemble(tl, ax, []);

            % Verify.
            testCase.verifyEqual(axes.Legend.Location, location, """LegendLocation"" property value should match.");
        end
    end
end
