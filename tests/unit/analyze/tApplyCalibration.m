classdef (TestTags = ["Unit", "Parallel"]) tApplyCalibration < MAGAnalysisTestCase
% TAPPLYCALIBRATION Unit tests for "applyCalibration" function.

    methods (Test)

        function noCalibration(testCase)

            % Set up.
            uncalibratedValue = [1, 2, 3; 4, 5, 6];

            calibrationStep = mag.process.Calibration();
            calibrationFile = testCase.createCalibrationFile();

            % Exercise.
            calibratedValue = calibrationStep.applyCalibration(uncalibratedValue, calibrationFile);

            % Verify.
            testCase.verifyEqual(calibratedValue, uncalibratedValue, "Calibrated value should match expectation.");
        end

        function applyScale(testCase)

            % Set up.
            uncalibratedValue = [1, 2, 3; 4, 5, 6];
            expectedValue = [2, 6, 3; 8, 15, 6];

            calibrationStep = mag.process.Calibration();
            calibrationFile = testCase.createCalibrationFile(Scale = [2, 3, 1]);

            % Exercise.
            calibratedValue = calibrationStep.applyCalibration(uncalibratedValue, calibrationFile);

            % Verify.
            testCase.verifyEqual(calibratedValue, expectedValue, "Calibrated value should match expectation.");
        end

        function applyMisalignment(testCase)

            % Set up.
            uncalibratedValue = [1, 2, 3; 4, 5, 6];
            expectedValue = [2, 1, -3; 5, 4, -6];

            calibrationStep = mag.process.Calibration();
            calibrationFile = testCase.createCalibrationFile(Misalignment = [0, 1, 0; 1, 0, 0; 0, 0, -1]);

            % Exercise.
            calibratedValue = calibrationStep.applyCalibration(uncalibratedValue, calibrationFile);

            % Verify.
            testCase.verifyEqual(calibratedValue, expectedValue, "Calibrated value should match expectation.");
        end

        function applyOffset(testCase)

            % Set up.
            uncalibratedValue = [1, 2, 3; 4, 5, 6];
            expectedValue = [3, -1, 4; 6, 2, 7];

            calibrationStep = mag.process.Calibration();
            calibrationFile = testCase.createCalibrationFile(Offset = [2, -3, 1]);

            % Exercise.
            calibratedValue = calibrationStep.applyCalibration(uncalibratedValue, calibrationFile);

            % Verify.
            testCase.verifyEqual(calibratedValue, expectedValue, "Calibrated value should match expectation.");
        end

        function applyCalibration(testCase)

            % Set up.
            uncalibratedValue = [1, 2, 3; 4, 5, 6];
            expectedValue = [8, -1, -2; 17, 5, -5];

            calibrationStep = mag.process.Calibration();
            calibrationFile = testCase.createCalibrationFile(Scale = [2, 3, 1], Misalignment = [0, 1, 0; 1, 0, 0; 0, 0, -1], Offset = [2, -3, 1]);

            % Exercise.
            calibratedValue = calibrationStep.applyCalibration(uncalibratedValue, calibrationFile);

            % Verify.
            testCase.verifyEqual(calibratedValue, expectedValue, "Calibrated value should match expectation.");
        end
    end

    methods (Access = private)

        function temporaryFile = createCalibrationFile(testCase, options)

            arguments (Input)
                testCase
                options.Scale (1, 3) double = ones(1, 3)
                options.Misalignment (3, 3) double = eye(3)
                options.Offset (1, 3) double = zeros(1, 3)
            end

            arguments (Output)
                temporaryFile (1, 1) string
            end

            temporaryFile = tempname() + ".txt";

            writematrix(vertcat(options.Scale, options.Misalignment, options.Offset), temporaryFile);
            testCase.addTeardown(@() delete(temporaryFile));
        end
    end
end
