classdef tDatetimeRangeSlider < mag.test.case.UITestCase
% TDATETIMERANGESLIDER Unit tests for
% "mag.app.component.DatetimeRangeSlider" class.

    properties (Constant, Access = private)
        InitialSliderLimits (1, 2) datetime = [datetime("yesterday", TimeZone = "UTC"), datetime("tomorrow", TimeZone = "UTC")]
        TestSliderLimits (1, 2) datetime = [datetime(2025, 12, 25, 1, 2, 3, TimeZone = "UTC"), datetime(2026, 1, 1, 23, 45, 16, TimeZone = "UTC")]
    end

    properties (TestParameter)
        DateSettings = {struct(Name = "Start", Index = 1, OtherName = "End", OtherIndex = 2), ...
            struct(Name = "End", Index = 2, OtherName = "Start", OtherIndex = 1)}
    end

    methods (Test)

        % Test that constructor builds a datetime range slider correctly.
        function constructor(testCase)

            % Set up.
            panel = mag.test.GraphicsTestUtilities.createPanel(testCase);

            datePickerLimits = testCase.InitialSliderLimits;
            datePickerLimits.TimeZone = "";

            % Exercise.
            slider = mag.app.component.DatetimeRangeSlider(panel);

            % Verify.
            testCase.assertNotEmpty(slider);
            testCase.assertClass(slider, "mag.app.component.DatetimeRangeSlider");

            testCase.verifyEqual(slider.Limits, testCase.InitialSliderLimits, "Slider limits should match expectation.");
            testCase.verifyEqual(slider.StartDatePicker.Limits, datePickerLimits, "Start date picker limits should match expectation.");
            testCase.verifyEqual(slider.EndDatePicker.Limits, datePickerLimits, "End date picker limits should match expectation.");

            testCase.verifyEqual(slider.StartTime, testCase.InitialSliderLimits(1), "Slider start date should match expectation.");
            testCase.verifyEqual(slider.EndTime, testCase.InitialSliderLimits(2), "Slider end date should match expectation.");
        end

        % Test that changing slider limits updates start and end date.
        function changeLimits(testCase)

            % Set up.
            slider = testCase.createTestSlider();

            datePickerLimits = dateshift(testCase.TestSliderLimits, "start", "day");
            datePickerLimits.TimeZone = "";

            % Exercise.
            slider.Limits = testCase.TestSliderLimits;

            % Verify.
            testCase.assertEqual(slider.Limits, testCase.TestSliderLimits, "Slider limits should be updated.");

            testCase.verifyEqual(slider.StartDatePicker.Limits, datePickerLimits, "Start date picker limits should be updated.");
            testCase.verifyEqual(slider.EndDatePicker.Limits, datePickerLimits, "End date picker limits should be updated.");

            testCase.verifyEqual(slider.StartTime, testCase.TestSliderLimits(1), "Slider start time should be updated.");
            testCase.verifyEqual(slider.EndTime, testCase.TestSliderLimits(2), "Slider end time should be updated.");
        end

        % Test set start/end date with slider.
        function setDateWithSlider(testCase, DateSettings)

            % Set up.
            slider = testCase.createTestSlider();

            value = 25;
            expectedDate = testCase.TestSliderLimits(1) + (range(testCase.TestSliderLimits) * value / (range(slider.SliderLimits)));

            % Exercise.
            % "drag" method not yet supported for SliderLimits.
            slider.Slider.Value(DateSettings.Index) = value;

            event = struct(Value = slider.Slider.Value);
            slider.Slider.ValueChangingFcn([], event);

            % Verify.
            testCase.verifyEqual(slider.(DateSettings.Name + "Time"), expectedDate, "Selected date should be updated to reflect slider value.");
            testCase.verifyEqual(slider.(DateSettings.OtherName + "Time"), testCase.TestSliderLimits(DateSettings.OtherIndex), "Other date should not be updated.");

            testCase.verifyEqual(slider.Slider.Value(DateSettings.Index), value, "Selected slider value should be updated to reflect date value.", AbsTol = 1e-6);
            testCase.verifyEqual(slider.Slider.Value(DateSettings.OtherIndex), slider.SliderLimits(DateSettings.OtherIndex), "Other slider value should not be updated.");
        end

        % Test set start/end date with date picker.
        function setDateWithPicker(testCase, DateSettings)

            % Set up.
            slider = testCase.createTestSlider();
            date = dateshift(testCase.TestSliderLimits(1) + days(2), "start", "day");

            expectedDate = date + mag.time.decodeTime(slider.(DateSettings.Name + "TimeField").Value);
            expectedValue = range(slider.SliderLimits) * (expectedDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            % Exercise.
            testCase.type(slider.(DateSettings.Name + "DatePicker"), date);

            % Verify.
            testCase.verifyEqual(slider.(DateSettings.Name + "Time"), expectedDate, "Selected date should be updated to reflect date value.");
            testCase.verifyEqual(slider.(DateSettings.OtherName + "Time"), testCase.TestSliderLimits(DateSettings.OtherIndex), "Other date should not be updated.");

            testCase.verifyEqual(slider.Slider.Value(DateSettings.Index), expectedValue, "Selected slider value should be updated to reflect date value.", AbsTol = 1e-6);
            testCase.verifyEqual(slider.Slider.Value(DateSettings.OtherIndex), slider.SliderLimits(DateSettings.OtherIndex), "Other slider value should not be updated.");
        end

        % Test set start/end date with time edit field.
        function setDateWithField(testCase, DateSettings)

            % Set up.
            slider = testCase.createTestSlider();
            time = "13:26:45";

            expectedDate = slider.(DateSettings.Name + "DatePicker").Value + mag.time.decodeTime(time);
            expectedDate.TimeZone = "UTC";

            expectedValue = range(slider.SliderLimits) * (expectedDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            % Exercise.
            testCase.type(slider.(DateSettings.Name + "TimeField"), time);

            % Verify.
            testCase.verifyEqual(slider.(DateSettings.Name + "Time"), expectedDate, "Selected date should be updated to reflect date value.");
            testCase.verifyEqual(slider.(DateSettings.OtherName + "Time"), testCase.TestSliderLimits(DateSettings.OtherIndex), "Other date should not be updated.");

            testCase.verifyEqual(slider.Slider.Value(DateSettings.Index), expectedValue, "Selected slider value should be updated to reflect date value.", AbsTol = 1e-6);
            testCase.verifyEqual(slider.Slider.Value(DateSettings.OtherIndex), slider.SliderLimits(DateSettings.OtherIndex), "Other slider value should not be updated.");
        end

        % Test reset method returns slider to original values.
        function reset(testCase)

            % Set up.
            slider = testCase.createTestSlider();

            testCase.type(slider.StartDatePicker, dateshift(testCase.TestSliderLimits(1) + days(2), "start", "day"));
            testCase.type(slider.EndTimeField, "11:25:13");

            testCase.assertNotEqual(slider.Slider.Value, slider.SliderLimits, "Slider values should be changed.");
            testCase.assertNotEqual(slider.StartTime, testCase.TestSliderLimits(1), "Slider start date should be changed.");
            testCase.assertNotEqual(slider.EndTime, testCase.TestSliderLimits(2), "Slider end date should be changed.");

            % Exercise.
            slider.reset();

            % Verify.
            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits, "Slider values should be reset.", AbsTol = 1e-6);

            testCase.verifyEqual(slider.StartTime, testCase.TestSliderLimits(1), "Slider start date should be reset.");
            testCase.verifyEqual(slider.EndTime, testCase.TestSliderLimits(2), "Slider end date should be reset.");
        end

        % Test error is thrown when start date is too early.
        function error_startDateTooEarly(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            % Exercise.
            testCase.type(slider.StartTimeField, "00:00");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.StartTime, testCase.TestSliderLimits(1), "Start time should not change.");
            testCase.verifyEqual(slider.EndTime, testCase.TestSliderLimits(2), "End time should not change.");

            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits, "Slider values should not change.", AbsTol = 1e-6);
        end

        % Test error is thrown when end date is too late.
        function error_endDateTooLate(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            % Exercise.
            testCase.type(slider.EndTimeField, "23:59");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.StartTime, testCase.TestSliderLimits(1), "Start time should not change.");
            testCase.verifyEqual(slider.EndTime, testCase.TestSliderLimits(2), "End time should not change.");

            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits, "Slider values should not change.", AbsTol = 1e-6);
        end

        % Test error is thrown when start date is after end date.
        function error_startDateAfterEndDate(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            date = dateshift(testCase.TestSliderLimits(1), "start", "day") + days(1);

            endDate = date + mag.time.decodeTime(slider.EndTimeField.Value);
            endValue = range(slider.SliderLimits) * (endDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            testCase.type(slider.EndDatePicker, date);

            % Exercise.
            testCase.type(slider.StartDatePicker, testCase.TestSliderLimits(2));

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.StartTime, testCase.TestSliderLimits(1), "Start time should not change.");
            testCase.verifyEqual(slider.EndTime, endDate, "End time should not change.");

            testCase.verifyEqual(slider.Slider.Value, [slider.SliderLimits(1), endValue], "Slider values should not change.", AbsTol = 1e-6);
        end

        % Test error is thrown when end date is before start date.
        function error_endDateBeforeStartDate(testCase)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            date = dateshift(testCase.TestSliderLimits(2), "start", "day") - days(1);

            startDate = date + mag.time.decodeTime(slider.StartTimeField.Value);
            startValue = range(slider.SliderLimits) * (startDate - testCase.TestSliderLimits(1)) / (range(testCase.TestSliderLimits));

            testCase.type(slider.StartDatePicker, date);

            % Exercise.
            testCase.type(slider.EndDatePicker, testCase.TestSliderLimits(1));

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.StartTime, startDate, "Start time should not change.");
            testCase.verifyEqual(slider.EndTime, testCase.TestSliderLimits(2), "End time should not change.");

            testCase.verifyEqual(slider.Slider.Value, [startValue, slider.SliderLimits(2)], "Slider values should not change.", AbsTol = 1e-6);
        end

        % Test error is thrown when start/end times have the wrong format.
        function error_invalidTime(testCase, DateSettings)

            % Set up.
            [slider, panel] = testCase.createTestSlider();

            % Exercise.
            testCase.type(slider.(DateSettings.Name + "TimeField"), "abc.001");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);

            testCase.verifyEqual(slider.StartTime, testCase.TestSliderLimits(1), "Start time should not change.");
            testCase.verifyEqual(slider.EndTime, testCase.TestSliderLimits(2), "End time should not change.");

            testCase.verifyEqual(slider.Slider.Value, slider.SliderLimits, "Slider values should not change.", AbsTol = 1e-6);
        end
    end

    methods (Access = private)

        function [slider, panel] = createTestSlider(testCase)

            panel = mag.test.GraphicsTestUtilities.createPanel(testCase, VisibleOverride = "on", ScrollableOverride = "on");
            panel.Scrollable = "on";

            slider = mag.app.component.DatetimeRangeSlider(panel);
            slider.Limits = testCase.TestSliderLimits;
        end
    end
end
