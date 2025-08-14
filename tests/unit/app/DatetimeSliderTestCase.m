classdef DatetimeSliderTestCase < mag.test.case.UITestCase
% DATETIMESLIDERTESTCASE Base class for datetime slider UI components.

    properties (Constant, Access = protected)
        InitialSliderLimits (1, 2) datetime = [datetime("yesterday", TimeZone = "UTC"), datetime("tomorrow", TimeZone = "UTC")]
        TestSliderLimits (1, 2) datetime = [datetime(2025, 12, 25, 1, 2, 3, TimeZone = "UTC"), datetime(2026, 1, 1, 23, 45, 16, TimeZone = "UTC")]
    end

    methods (Access = protected)

        function [slider, panel] = createTestSlider(testCase, sliderType)

            arguments
                testCase
                sliderType (1, 1) string {mustBeMember(sliderType, ["DatetimeSlider", "DatetimeRangeSlider"])} = "DatetimeRangeSlider"
            end

            panel = mag.test.GraphicsTestUtilities.createPanel(testCase, PositionOverride = [100, 100, 750, 500], VisibleOverride = "on", ScrollableOverride = "on");
            panel.Scrollable = "on";

            slider = mag.app.component.(sliderType)(panel);
            slider.Limits = testCase.TestSliderLimits;

            testCase.assumeTrue(panel.isInScrollView(slider), "Component outside the viewable area. Test skipped.");
        end
    end
end
