classdef (TestTags = ["Unit", "Parallel"]) tColormap < MAGStyleTestCase & GridSupportTestCase & LegendSupportTestCase
% TCOLORMAP Unit tests for "mag.graphics.style.Colormap" class.

    properties (Constant)
        ClassName = "mag.graphics.style.Colormap"
    end

    properties (TestParameter)
        AllowedClassName = {'mag.graphics.chart.Spectrogram'}
        ForbiddenClassName = tColormap.getForbiddenClassNames()
    end

    methods (Test)

        % Test that only spectrogram can be used as chart.
        function allowedChart(~, AllowedClassName)
            mag.graphics.style.Colormap(Charts = feval(AllowedClassName));
        end

        % Test that error is thrown for forbidden charts.
        function forbiddenChart(testCase, ForbiddenClassName)

            testCase.verifyError(@() mag.graphics.style.Colormap(Charts = feval(ForbiddenClassName)), "MATLAB:validation:UnableToConvert", ...
                "Only ""mag.graphics.chart.Spectrogram"" is allowed as chart.");
        end

        % Test that label of colorbar can be set.
        function colorbar(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            label = 'c label';

            % Exercise.
            style = mag.graphics.style.Colormap(CLabel = label);

            axes = style.assemble(tl, ax, []);

            % Verify.
            testCase.assertNotEmpty(axes, "Axes object should still exist.");
            testCase.verifySameHandle(axes, ax, "Axes should not be overwritten.");

            colorbar = findobj(tl, Type = "Colorbar");
            testCase.assertNotEmpty(colorbar, "Colorbar should exist.");

            testCase.verifyEqual(colorbar.Label.String, label, """CLabel"" property value should match.");
        end

        % Test that colormap value can be set.
        function colormap(testCase)

            % Set up.
            [tl, ax] = mag.test.GraphicsTestUtilities.createFigure(testCase);

            map = 'cool';

            % Exercise.
            style = mag.graphics.style.Colormap(Map = map);

            axes = style.assemble(tl, ax, []);

            % Verify.
            testCase.assertNotEmpty(axes, "Axes object should still exist.");
            testCase.verifySameHandle(axes, ax, "Axes should not be overwritten.");

            testCase.verifyEqual(colormap(axes), feval(map), """Colormap"" value should match."); %#ok<FVAL>
        end
    end

    methods (Static, Access = private)

        function classNames = getForbiddenClassNames()

            metaPackage = meta.package.fromName("mag.graphics.chart");

            metaClass = metaPackage.ClassList;
            metaClass = metaClass((metaClass < ?mag.graphics.chart.Chart) & (metaClass ~= ?mag.graphics.chart.Spectrogram));

            classNames = {metaClass.Name};
        end
    end
end
