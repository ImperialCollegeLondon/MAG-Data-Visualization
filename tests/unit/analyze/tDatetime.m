classdef tDatetime < MAGAnalysisTestCase
% TDATETIME Unit tests for "mag.process.Datetime" class.

    methods (Test)

        function apply(testCase)

            % Set up.
            rightNow = datetime("now", TimeZone = "UTC");
            posixNow = posixtime(rightNow);

            magNow = posixNow - mag.time.Constant.Epoch;
            data = table(magNow, VariableNames = "t");

            datetimeStep = mag.process.Datetime();

            % Exercise.
            convertedData = datetimeStep.apply(data, []);

            % Verify.
            testCase.verifyLessThan(convertedData.t - rightNow, seconds(1e-5), ...
                "Converted time should match expectation.");
        end

        function apply_customTimeVariable(testCase)

            % Set up.
            rightNow = datetime("now", TimeZone = "UTC");
            posixNow = posixtime(rightNow);

            magNow = posixNow - mag.time.Constant.Epoch;
            data = table(magNow, VariableNames = "time");

            datetimeStep = mag.process.Datetime(TimeVariable = "time");

            % Exercise.
            convertedData = datetimeStep.apply(data, []);

            % Verify.
            testCase.verifyLessThan(convertedData.time - rightNow, seconds(1e-5), ...
                "Converted time should match expectation.");
        end
    end
end