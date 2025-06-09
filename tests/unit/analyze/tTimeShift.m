classdef tTimeShift < MAGAnalysisTestCase
% TTIMESHIFT Unit tests for "mag.process.TimeShift" class.

    methods (Test)

        function timeShift_none(testCase)

            % Set up.
            data = testCase.createTestData();
            metadata = mag.meta.Science(Sensor = mag.meta.Sensor.FIB);

            % Exercise.
            timeShiftStep = mag.process.TimeShift();
            processedData = timeShiftStep.apply(data, metadata);

            % Verify.
            testCase.verifyEqual(processedData.Time, data.Time, "No time shift should be applied.");
        end

        function timeShift_fib(testCase)

            % Set up.
            data = testCase.createTestData();
            metadata = mag.meta.Science(Sensor = mag.meta.Sensor.FIB);

            dt = milliseconds(1);

            % Exercise.
            timeShiftStep = mag.process.TimeShift(TimeShifts = dictionary(metadata.Sensor, dt));
            processedData = timeShiftStep.apply(data, metadata);

            % Verify.
            testCase.verifyThat(matlab.unittest.constraints.EveryElementOf(processedData.Time - data.Time), ...
                matlab.unittest.constraints.IsEqualTo(dt), "Time shift should be correctly applied.");
        end
    end
end
