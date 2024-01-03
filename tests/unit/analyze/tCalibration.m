classdef tCalibration < MAGAnalysisTestCase
% TCALIBRATION Unit tests for "Calibration" class.

    methods (Test)

        % Load all calibration test files, and make sure none of the values
        % are NaNs.
        function load(testCase)

            files = dir(fullfile(mag.process.Calibration.FileLocation, "*.txt"));

            for f = files'

                data = readmatrix(fullfile(f.folder, f.name));
                testCase.verifyFalse(any(ismissing(data), "all"), "Calibration data should not be interpreted as NaN.");
            end
        end

        % Verify that default calibration is selected, if sensor model does
        % not have specific calibration data.
        function default_unknownModel(testCase)

            % Set up.
            uncalibratedData = testCase.createTestData();
            metaData = mag.meta.Science(Model = "EM1");

            % Exercise.
            calibrationStep = mag.process.Calibration();
            calibratedData = calibrationStep.apply(uncalibratedData, metaData);

            % Verify.
            testCase.verifyEqual(calibratedData, uncalibratedData, "Calibrated value should match expectation.");
        end

        % Verify that correct calibration is selected based on sensor.
        function calibration_sensor(testCase)

            % Set up.
            uncalibratedData = testCase.createTestData();
            metaData = mag.meta.Science(Model = "FM5");

            expectedData = uncalibratedData;
            expectedData{:, "x"} = 1.075387;
            expectedData{:, "y"} = 0.001632 + 1.047678;
            expectedData{:, "z"} = -0.001174 - 0.004159 + 1.053048;

            % Exercise.
            calibrationStep = mag.process.Calibration();
            calibratedData = calibrationStep.apply(uncalibratedData, metaData);

            % Verify.
            testCase.verifyThat(calibratedData, matlab.unittest.constraints.IsEqualTo(expectedData, Within = matlab.unittest.constraints.AbsoluteTolerance(1e-10)), ...
                "Calibrated value should match expectation.");
        end

        % Verify that correct calibration is selected based on range.
        function calibration_range(testCase)

            % Set up.
            uncalibratedData = testCase.createTestData(Range = 3 * ones(3, 1));
            metaData = mag.meta.Science(Model = "FM5");

            expectedData = uncalibratedData;
            expectedData{:, "x"} = 1.014961;
            expectedData{:, "y"} = 0.001110 + 0.995020;
            expectedData{:, "z"} = 0.000553 - 0.005064 + 0.995464;

            % Exercise.
            calibrationStep = mag.process.Calibration();
            calibratedData = calibrationStep.apply(uncalibratedData, metaData);

            % Verify.
            testCase.verifyThat(calibratedData, matlab.unittest.constraints.IsEqualTo(expectedData, Within = matlab.unittest.constraints.AbsoluteTolerance(1e-10)), ...
                "Calibrated value should match expectation.");
        end

        % Verify that correct calibration is selected based on temperature.
        function calibration_temperature(testCase)

            % Set up.
            uncalibratedData = testCase.createTestData();
            metaData = mag.meta.Science(Model = "FM5");

            expectedData = uncalibratedData;
            expectedData{:, "x"} = 1.075432;
            expectedData{:, "y"} = 0.001009 + 1.047721;
            expectedData{:, "z"} = -0.001196 - 0.003928 + 1.053087;

            % Exercise.
            calibrationStep = mag.process.Calibration(Temperature = "Cool");
            calibratedData = calibrationStep.apply(uncalibratedData, metaData);

            % Verify.
            testCase.verifyThat(calibratedData, matlab.unittest.constraints.IsEqualTo(expectedData, Within = matlab.unittest.constraints.AbsoluteTolerance(1e-10)), ...
                "Calibrated value should match expectation.");
        end

        % Verify that correct calibration is selected based on all
        % variables.
        function calibration_all(testCase)

            % Set up.
            uncalibratedData = testCase.createTestData(Range = 2 * ones(3, 1));
            metaData = mag.meta.Science(Model = "FM4");

            expectedData = uncalibratedData;
            expectedData{:, "x"} = 1.016675;
            expectedData{:, "y"} = -0.001415 + 0.996880;
            expectedData{:, "z"} = 0.001770 - 0.004966 + 0.997683;

            % Exercise.
            calibrationStep = mag.process.Calibration(Temperature = "Cold");
            calibratedData = calibrationStep.apply(uncalibratedData, metaData);

            % Verify.
            testCase.verifyThat(calibratedData, matlab.unittest.constraints.IsEqualTo(expectedData, Within = matlab.unittest.constraints.AbsoluteTolerance(1e-10)), ...
                "Calibrated value should match expectation.");
        end
    end
end
