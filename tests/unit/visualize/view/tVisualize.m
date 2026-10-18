classdef (TestTags = ["Unit", "Parallel"]) tVisualize < MAGViewTestCase
% TVISUALIZE Unit tests for "mag.graphics.visualize" function.

    methods (Test)

        % Test that empty figure is generated when no arguments.
        function empty(testCase)

            % Exercise.
            fig = mag.graphics.visualize();

            % Verify.
            testCase.assertNumElements(fig, 1, "One and only one figure should be created.");
            testCase.assertClass(fig, "matlab.ui.Figure", "Figure should have expected class.");

            tl = fig.Children;
            testCase.assertNumElements(tl, 1, "Figure should have one and only one child.");
            testCase.assertClass(tl, "matlab.graphics.layout.TiledChartLayout", "Figure child should have expected class.");

            testCase.verifyEmpty(tl.Children, "Tiled layout should have no children.");
        end

        % Test that errors are re-thrown.
        function error(testCase)
            testCase.verifyError(@() mag.graphics.visualize(1), "MATLAB:functionValidation:RepeatingInputsNotInGroups", "Error should be re-thrown.");
        end
    end
end
