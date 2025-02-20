classdef tDecodeDate < matlab.unittest.TestCase
% TDECODEDATE Unit tests for "mag.time.decodeDate" function.

    properties (TestParameter)
        ValidDate = {
            struct(Value = "10/04/2024", Expected = datetime(2024, 4, 10, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format)), ...
            struct(Value = "25-Jun-2025", Expected = datetime(2025, 6, 25, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format)), ...
            struct(Value = "23-09-2025", Expected = datetime(2025, 9, 23, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format))}
        InvalidDate = {"01.02.2003", "12-13-2014"}
    end

    methods (Test)

        % Test that supported dates can be decoded.
        function decodeDate(testCase, ValidDate)

            % Exercise.
            actualTime = mag.time.decodeDate(ValidDate.Value);

            % Verify.
            testCase.verifyEqual(actualTime, ValidDate.Expected, "Decoded time should match expectation.");
        end

        % Test that error is thrown when invalid date is used.
        function decodeDate_fail(testCase, InvalidDate)

            testCase.verifyError(@() mag.time.decodeDate(InvalidDate), ?MException, ...
                "Error should be thrown when value does not match regex.");
        end
    end
end
