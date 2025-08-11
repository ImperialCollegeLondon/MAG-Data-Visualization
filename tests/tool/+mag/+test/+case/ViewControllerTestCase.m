classdef (Abstract) ViewControllerTestCase < mag.test.case.GraphicsTestCase
% VIEWCONTROLLERTESTCASE Base class for all view-controller tests.

    properties (Constant, Access = protected)
        DynamicPlaceholder (1, 1) string = "dynamic (default)";
    end

    methods (Access = protected)

        function panel = createTestPanel(testCase, varargin)
            panel = mag.test.GraphicsTestUtilities.createPanel(testCase, varargin{:});
        end

        function verifyStartEndDateButtons(testCase, control, options)
        % VERIFYSTARTENDDATEBUTTONS Verify start date and end date buttons
        % are populated correctly.

            arguments
                testCase
                control (1, 1) mag.app.mixin.StartEndDate
                options.Rows (1, 2) double = [1, 2]
                options.Columns (1, 2) double = [1, 3]
            end

            testCase.assertNotEmpty(control.Slider, "Slider should not be empty.");
            slider = control.Slider;

            testCase.verifyEqual(slider.Layout, ...
                matlab.ui.layout.GridLayoutOptions(Row = options.Rows, Column = options.Columns), ...
                "Start date picker layout should match expectation.");
        end
    end
end
