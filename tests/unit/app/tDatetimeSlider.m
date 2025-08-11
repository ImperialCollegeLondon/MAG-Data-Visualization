classdef tDatetimeSlider < mag.test.case.UITestCase
% TDATETIMESLIDER Unit tests for "mag.app.component.DatetimeSlider" class.

    properties (Constant, Access = private)
        InitialSliderLimits (1, 2) datetime = [datetime("yesterday", TimeZone = "UTC"), datetime("tomorrow", TimeZone = "UTC")]
        TestSliderLimits (1, 2) datetime = [datetime(2025, 12, 25, 1, 2, 3, TimeZone = "UTC"), datetime(2026, 1, 1, 23, 45, 16, TimeZone = "UTC")]
    end

    methods (Test)

        % Test that constructor builds a datetime range slider correctly.
        function constructor(testCase)

            % Set up.
            panel = mag.test.GraphicsTestUtilities.createPanel(testCase);

            datePickerLimits = testCase.InitialSliderLimits;
            datePickerLimits.TimeZone = "";

            % Exercise.
            slider = mag.app.component.DatetimeSlider(panel);

            % Verify.
            testCase.assertNotEmpty(slider);
            testCase.assertClass(slider, "mag.app.component.DatetimeSlider");

            testCase.verifyEqual(slider.Limits, testCase.InitialSliderLimits, "Slider limits should match expectation.");
            testCase.verifyEqual(slider.DatePicker.Limits, datePickerLimits, "Start date picker limits should match expectation.");
            testCase.verifyEqual(slider.SelectedTime, testCase.InitialSliderLimits(1), "Slider selected date should match expectation.");
        end

        % Test that changing slider limits updates date.
        function changeLimits(testCase)

            % Set up.
            slider = testCase.createTestSlider();

            datePickerLimits = dateshift(testCase.TestSliderLimits, "start", "day");
            datePickerLimits.TimeZone = "";

            % Exercise.
            slider.Limits = testCase.TestSliderLimits;

            % Verify.
            testCase.assertEqual(slider.Limits, testCase.TestSliderLimits, "Slider limits should be updated.");

            testCase.verifyEqual(slider.DatePicker.Limits, datePickerLimits, "Start date picker limits should be updated.");
            testCase.verifyEqual(slider.SelectedTime, testCase.TestSliderLimits(1), "Slider selected time should be updated.");
        end

        % Test set date with slider.
        function setDateWithSlider(testCase)

            % Set up.
            slider = testCase.createTestSlider();

            value = 25;
            expectedDate = testCase.TestSliderLimits(1) + (range(testCase.TestSliderLimits) * value / (range(slider.SliderLimits)));

            % Exercise.
            testCase.drag(slider.Slider, 0, value);

            % Verify.
            testCase.verifyEqual(slider.SelectedTime, expectedDate, "Selected date should be updated to reflect slider value.");
            testCase.verifyEqual(slider.Slider.Value, value, "Selected slider value should be updated to reflect date value.", AbsTol = 1e-6);
        end

        % Test set date with date picker.
        function setDateWithPicker(testCase)

            % Set up.
            slider = testCase.createTestSlider();
            date = dateshift(testCase.TestSliderLimits(1) + days(2), "start", "day");

            expectedDate = date + mag.time.decodeTime(slider.TimeField.Value);
            expectedValue = range(slider.SliderLimits) * (expectedDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            % Exercise.
            testCase.type(slider.DatePicker, date);

            % Verify.
            testCase.verifyEqual(slider.SelectedTime, expectedDate, "Selected date should be updated to reflect date value.");
            testCase.verifyEqual(slider.Slider.Value, expectedValue, "Selected slider value should be updated to reflect date value.", AbsTol = 1e-6);
        end

        % Test set date with time edit field.
        function setDateWithField(testCase)

            % Set up.
            slider = testCase.createTestSlider();
            time = "13:26:45";

            expectedDate = slider.DatePicker.Value + mag.time.decodeTime(time);
            expectedDate.TimeZone = "UTC";

            expectedValue = range(slider.SliderLimits) * (expectedDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            % Exercise.
            testCase.type(slider.TimeField, time);

            % Verify.
            testCase.verifyEqual(slider.SelectedTime, expectedDate, "Selected date should be updated to reflect date value.");
            testCase.verifyEqual(slider.Slider.Value, expectedValue, "Selected slider value should be updated to reflect date value.", AbsTol = 1e-6);
        end

        % Test reset method returns slider to original values.
        function reset(testCase)

            % Set up.
            slider = testCase.createTestSlider();

            testCase.type(slider.DatePicker, dateshift(testCase.TestSliderLimits(1) + days(2), "start", "day"));

            testCase.assertNotEqual(slider.Slider.Value, slider.SliderLimits(1), "Slider values should be changed.");
            testCase.assertNotEqual(slider.SelectedTime, testCase.TestSliderLimits(1), "Slider selected date should be changed.");

            % Exercise.
            slider.reset();

            % Verify.
            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits(1), "Slider values should be reset.", AbsTol = 1e-6);
            testCase.verifyEqual(slider.SelectedTime, testCase.TestSliderLimits(1), "Slider date should be reset.");
        end

        % Test error is thrown when date is too early.
        function error_dateTooEarly(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            % Exercise.
            testCase.type(slider.TimeField, "00:00");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.SelectedTime, testCase.TestSliderLimits(1), "Start time should not change.");
            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits(1), "Slider values should not change.", AbsTol = 1e-6);
        end

        % Test error is thrown when date is too late.
        function error_dateTooLate(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            expectedDate = dateshift(testCase.TestSliderLimits(2), "start", "day") + mag.time.decodeTime(slider.TimeField.Value);
            expectedValue = range(slider.SliderLimits) * (expectedDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            testCase.type(slider.DatePicker, testCase.TestSliderLimits(2));

            % Exercise.
            testCase.type(slider.TimeField, "23:59");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.SelectedTime, expectedDate, "Start time should not change.");
            testCase.verifyEqual(slider.Slider.Value, expectedValue, "Slider values should not change.", AbsTol = 1e-6);
        end

        % Test error is thrown when times have the wrong format.
        function error_invalidTime(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            % Exercise.
            testCase.type(slider.TimeField, "abc.001");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.SelectedTime, testCase.TestSliderLimits(1), "Start time should not change.");
            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits(1), "Slider values should not change.", AbsTol = 1e-6);
        end
    end

    methods (Access = private)

        function [slider, panel] = createTestSlider(testCase)

            panel = mag.test.GraphicsTestUtilities.createPanel(testCase, VisibleOverride = "on");
            panel.Scrollable = "on";

            slider = mag.app.component.DatetimeSlider(panel);
            slider.Limits = testCase.TestSliderLimits;
        end
    end
end
