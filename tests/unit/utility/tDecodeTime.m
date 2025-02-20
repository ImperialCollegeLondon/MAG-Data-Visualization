classdef tDecodeTime < matlab.unittest.TestCase
% TDECODETIME Unit tests for "mag.time.decodeTime" function.

    properties (TestParameter)
        ValidTime = {
            struct(Value = "10:30", Expected = duration(10, 30, 0)), ...
            struct(Value = "10:45:27", Expected = duration(10, 45, 27)), ...
            struct(Value = "10:39:26.1253", Expected = duration(10, 39, 26, 125.3))}
        InvalidTime = {"10:30:45:27", "10:39:26.1253.1253"}
    end

    methods (Test)

        % Test that supported times can be decoded.
        function decodeTime(testCase, ValidTime)

            % Exercise.
            actualTime = mag.time.decodeTime(ValidTime.Value);

            % Verify.
            testCase.verifyEqual(actualTime, ValidTime.Expected, "Decoded time should match expectation.");
        end

        % Test that error is thrown when invalid time is used.
        function decodeTime_fail(testCase, InvalidTime)

            testCase.verifyError(@() mag.time.decodeTime(InvalidTime), ?MException, ...
                "Error should be thrown when value does not match regex.");
        end
    end
end
