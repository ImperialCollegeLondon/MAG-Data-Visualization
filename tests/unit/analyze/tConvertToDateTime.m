classdef tConvertToDateTime < MAGAnalysisTestCase
% TCONVERTTODATETIME Unit tests for "convertToDateTime" function.

    methods (Test)

        function convertToDateTime(testCase)

            % Set up.
            rightNow = datetime("now", TimeZone = "UTC");
            posixNow = posixtime(rightNow);

            magNow = posixNow - mag.time.Constant.Epoch;

            dateTimeStep = mag.process.DateTime();

            % Exercise.
            convertedNow = dateTimeStep.apply(magNow, []);

            % Verify.
            testCase.verifyLessThan(convertedNow - rightNow, seconds(1e-5), ...
                "Converted time should match expectation.");
        end
    end
end
