classdef tCombineDateAndTime < matlab.unittest.TestCase
% TCOMBINEDATEANDTIME Unit tests for "mag.app.internal.combineDateAndTime"
% function.

    properties (TestParameter)
        ValidDate = {datetime("today"), NaT}
        ValidTime = {struct(Value = "12:30", Expected = duration(12, 30, 0)), ...
            struct(Value = "23:59", Expected = duration(23, 59, 0)), ...
            struct(Value = "01:10", Expected = duration(1, 10, 0)), ...
            struct(Value = "1:10", Expected = duration(1, 10, 0)), ...
            struct(Value = "1:2:3", Expected = duration(1, 2, 3)), ...
            struct(Value = "02:01:30", Expected = duration(2, 1, 30)), ...
            struct(Value = "03:10:59.123456", Expected = duration(3, 10, 59, 123.456))}
        InvalidTime = {"abc", "10 30", "10:30 UTC"}
    end

    methods (Test)

        % Test that datetime is processed correctly.
        function datetimeOnly(testCase, ValidDate)

            % Set up.
            inputDate = ValidDate;

            expectedDate = inputDate;
            expectedDate.Format = mag.time.Constant.Format;
            expectedDate.TimeZone = mag.time.Constant.TimeZone;

            % Exercise.
            actualDate = mag.app.internal.combineDateAndTime(inputDate);

            % Verify.
            testCase.verifyEqual(actualDate, expectedDate, "Processed datetime should match expectation.");
        end

        % Test that datetime and time are processed correctly.
        function datetimeTime(testCase, ValidDate, ValidTime)

            % Set up.
            inputDate = ValidDate;

            expectedDate = inputDate;
            expectedDate.Format = mag.time.Constant.Format;
            expectedDate.TimeZone = mag.time.Constant.TimeZone;

            expectedDateTime = expectedDate + ValidTime.Expected;

            % Exercise.
            actualDateTime = mag.app.internal.combineDateAndTime(inputDate, ValidTime.Value);

            % Verify.
            testCase.verifyEqual(actualDateTime, expectedDateTime, "Processed datetime should match expectation.");
        end

        % Test that error is thrown when time is in incorrect format.
        function datetimeTime_invalidTime(testCase, ValidDate, InvalidTime)

            testCase.verifyError(@() mag.app.internal.combineDateAndTime(ValidDate, InvalidTime), "", ...
                "Error should be thrown on invalid time.");
        end
    end
end
