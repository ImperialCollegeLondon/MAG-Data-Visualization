classdef (Abstract) ViewControllerTestCase < mag.test.case.GraphicsTestCase
% VIEWCONTROLLERTESTCASE Base class for all view-controller tests.

    properties (Constant, Access = protected)
        DynamicPlaceholder (1, 1) string = "dynamic (default)";
    end

    methods (Access = protected)

        function panel = createTestPanel(testCase, options)
        % CREATETESTPANEL Create "uipanel" to add controls to.

            arguments
                testCase
                options.VisibleOverride (1, 1) matlab.lang.OnOffSwitchState = "off"
            end

            f = uifigure(Visible = options.VisibleOverride);
            panel = uipanel(f, Position = [1, 1, f.InnerPosition(3:4)]);

            testCase.addTeardown(@() close(f));
        end

        function verifyStartEndDateButtons(testCase, control, options)
        % VERIFYSTARTENDDATEBUTTONS Verify start date and end date buttons
        % are populated correctly.

            arguments
                testCase
                control (1, 1) mag.app.mixin.StartEndDate
                options.StartDateRow (1, 1) double
                options.StartDatePickerColumn (1, :) double = 2
                options.StartTimeFieldColumn (1, :) double = 3
                options.EndDateRow (1, 1) double
                options.EndDatePickerColumn (1, :) double = 2
                options.EndTimeFieldColumn (1, :) double = 3
            end

            testCase.assertNotEmpty(control.StartDatePicker, "Start date picker should not be empty.");
            testCase.assertNotEmpty(control.StartTimeField, "Start time field should not be empty.");
            testCase.assertNotEmpty(control.EndDatePicker, "End date picker should not be empty.");
            testCase.assertNotEmpty(control.EndTimeField, "End time field should not be empty.");

            testCase.verifyEqual(control.StartDatePicker.Layout, ...
                matlab.ui.layout.GridLayoutOptions(Row = options.StartDateRow, Column = options.StartDatePickerColumn), ...
                "Start date picker layout should match expectation.");

            testCase.verifyEqual(control.StartTimeField.Placeholder, 'HH:mm:ss.SSS', "Start time field placeholder should match expectation.");
            testCase.verifyEqual(control.StartTimeField.Layout, ...
                matlab.ui.layout.GridLayoutOptions(Row = options.StartDateRow, Column = options.StartTimeFieldColumn), ...
                "Start time field layout should match expectation.");

            testCase.verifyEqual(control.EndDatePicker.Layout, ...
                matlab.ui.layout.GridLayoutOptions(Row = options.EndDateRow, Column = options.EndDatePickerColumn), ...
                "End date picker layout should match expectation.");

            testCase.verifyEqual(control.EndTimeField.Placeholder, 'HH:mm:ss.SSS', "End time field placeholder should match expectation.");
            testCase.verifyEqual(control.EndTimeField.Layout, ...
                matlab.ui.layout.GridLayoutOptions(Row = options.EndDateRow, Column = options.EndTimeFieldColumn), ...
                "End time field layout should match expectation.");
        end
    end
end
