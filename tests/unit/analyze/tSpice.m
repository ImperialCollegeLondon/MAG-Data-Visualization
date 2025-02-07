classdef tSpice < MAGAnalysisTestCase
% TSPICE Unit tests for "mag.process.Spice" classes.

    methods (Test)

        % Test that conversion from MET to UTC is correct.
        function convertMETToUTC(testCase)

            % Set up.
            data = testCase.createTestData();

            expectedTimes = [datetime("14-Jan-2025 17:58:17.519466239", TimeZone = "UTC", Format = mag.time.Constant.Format); ...
                datetime("14-Jan-2025 17:58:25.519389952", TimeZone = "UTC", Format = mag.time.Constant.Format)];

            % Exercise.
            spiceStep = mag.process.Spice(TimeVariable = "time_variable", Mission = "IMAP");
            processedData = spiceStep.apply(data);

            actualTimes = processedData.time_variable;

            % Verify.
            millisecondTolerance = 0.5;

            testCase.verifyLessThanOrEqual(abs(milliseconds(actualTimes - expectedTimes)), millisecondTolerance, ...
                compose("Time should be within %s.", milliseconds(millisecondTolerance)));
        end
    end

    methods (Static, Access = protected)

        function data = createTestData()

            fineTimeMax = double(intmax("uint16"));

            data = table(...
                [474573500 + (34022 / fineTimeMax); 474573508 + (34017 / fineTimeMax)], ...
                VariableNames = "time_variable");
        end
    end
end
