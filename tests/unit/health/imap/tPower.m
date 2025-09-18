classdef tPower < matlab.unittest.TestCase
% TPOWER Unit tests for "mag.imap.health.Power" class.

    properties (TestParameter)
        FailHigh = { ...
            struct(Property = "P1V5V", Column = "P1V5V", Value = 1.6), ...
            struct(Property = "P1V8V", Column = "P1V8V", Value = 2.2), ...
            struct(Property = "P3V3V", Column = "P3V3V", Value = 4), ...
            struct(Property = "P2V5V", Column = "P2V5V", Value = 3), ...
            struct(Property = "P8V", Column = "P8V", Value = 11), ...
            struct(Property = "N8V", Column = "N8V", Value = -8), ...
            struct(Property = "ICUTemperature", Column = "ICU_TEMP", Value = 70), ...
            struct(Property = "FOBTemperature", Column = "FOB_TEMP", Value = 100), ...
            struct(Property = "FIBTemperature", Column = "FIB_TEMP", Value = 100)}
        FailLow = { ...
            struct(Property = "P1V5V", Column = "P1V5V", Value = 1.3), ...
            struct(Property = "P1V8V", Column = "P1V8V", Value = 1.5), ...
            struct(Property = "P3V3V", Column = "P3V3V", Value = 2.5), ...
            struct(Property = "P2V5V", Column = "P2V5V", Value = 2), ...
            struct(Property = "P8V", Column = "P8V", Value = 8), ...
            struct(Property = "N8V", Column = "N8V", Value = -11), ...
            struct(Property = "ICUTemperature", Column = "ICU_TEMP", Value = -40), ...
            struct(Property = "FOBTemperature", Column = "FOB_TEMP", Value = -55), ...
            struct(Property = "FIBTemperature", Column = "FIB_TEMP", Value = -55)}
        BorderlineHigh = { ...
            struct(Property = "P1V5V", Column = "P1V5V", Value = 1.54), ...
            struct(Property = "P1V8V", Column = "P1V8V", Value = 1.85), ...
            struct(Property = "P3V3V", Column = "P3V3V", Value = 3.39), ...
            struct(Property = "P2V5V", Column = "P2V5V", Value = 2.57), ...
            struct(Property = "P8V", Column = "P8V", Value = 9.81), ...
            struct(Property = "N8V", Column = "N8V", Value = -9.45), ...
            struct(Property = "P2V4V", Column = "P2V4V", Value = -2.37), ...
            struct(Property = "P1V5I", Column = "P1V5I", Value = 450), ...
            struct(Property = "P1V8I", Column = "P1V8I", Value = 50), ...
            struct(Property = "P3V3I", Column = "P3V3I", Value = 150), ...
            struct(Property = "P2V5I", Column = "P2V5I", Value = 110), ...
            struct(Property = "P8VI", Column = "P8VI", Value = 250), ...
            struct(Property = "N8VI", Column = "N8VI", Value = 200), ...
            struct(Property = "ICUTemperature", Column = "ICU_TEMP", Value = 51), ...
            struct(Property = "FOBTemperature", Column = "FOB_TEMP", Value = 60), ...
            struct(Property = "FIBTemperature", Column = "FIB_TEMP", Value = 60)}
        BorderlineLow = { ...
            struct(Property = "P1V5V", Column = "P1V5V", Value = 1.51), ...
            struct(Property = "P1V8V", Column = "P1V8V", Value = 1.81), ...
            struct(Property = "P3V3V", Column = "P3V3V", Value = 3.34), ...
            struct(Property = "P2V5V", Column = "P2V5V", Value = 2.53), ...
            struct(Property = "P8V", Column = "P8V", Value = 9.45), ...
            struct(Property = "N8V", Column = "N8V", Value = -9.81), ...
            struct(Property = "P2V4V", Column = "P2V4V", Value = -2.32), ...
            struct(Property = "P1V5I", Column = "P1V5I", Value = 350), ...
            struct(Property = "P1V8I", Column = "P1V8I", Value = 10), ...
            struct(Property = "P3V3I", Column = "P3V3I", Value = 100), ...
            struct(Property = "P2V5I", Column = "P2V5I", Value = 50), ...
            struct(Property = "P8VI", Column = "P8VI", Value = 100), ...
            struct(Property = "N8VI", Column = "N8VI", Value = 50), ...
            struct(Property = "ICUTemperature", Column = "ICU_TEMP", Value = -26), ...
            struct(Property = "FOBTemperature", Column = "FOB_TEMP", Value = -46), ...
            struct(Property = "FIBTemperature", Column = "FIB_TEMP", Value = -46)}
        SaturationFlag = { ...
            struct(Property = "MAGOSATFLAGX", Name = "MAGo x-axis"), ...
            struct(Property = "MAGOSATFLAGY", Name = "MAGo y-axis"), ...
            struct(Property = "MAGOSATFLAGZ", Name = "MAGo z-axis"), ...
            struct(Property = "MAGISATFLAGX", Name = "MAGi x-axis"), ...
            struct(Property = "MAGISATFLAGY", Name = "MAGi y-axis"), ...
            struct(Property = "MAGISATFLAGZ", Name = "MAGi z-axis")}
    end

    methods (Test)

        % Test that valid power values pass all checks.
        function allChecksPass(testCase)

            % Set up.
            pwr = testCase.createTestPowerHK();

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            testCase.verifyEqual(matlab.unittest.constraints.EveryElementOf([check.Results.Status]), mag.health.Status.Pass, "All checks should pass.");
        end

        % Test that no checks are run if no power HK is available.
        function noPowerHK(testCase)

            % Set up.
            instrument = mag.imap.Instrument();
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertEmpty(check.Results, "Results should not have been populated.");
        end

        % Test that checks fail when value is higher than danger high.
        function dangerHigh(testCase, FailHigh)

            % Set up.
            pwr = testCase.createTestPowerHK();
            pwr.Data.(FailHigh.Column)(1) = FailHigh.Value;

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locFail = [check.Results.Status] == mag.health.Status.Fail;
            testCase.assertEqual(nnz(locFail), 1, "Only 1 check should fail.");

            failedCheck = check.Results(locFail);
            testCase.verifyEqual(failedCheck.Name, mag.imap.health.Power.PropertyToHumanReadableConversion(FailHigh.Property), "Failed check name should match expectation.");
        end

        % Test that checks fail when value is lower than danger low.
        function dangerLow(testCase, FailLow)

            % Set up.
            pwr = testCase.createTestPowerHK();
            pwr.Data.(FailLow.Column)(1) = FailLow.Value;

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locFail = [check.Results.Status] == mag.health.Status.Fail;
            testCase.assertEqual(nnz(locFail), 1, "Only 1 check should fail.");

            failedCheck = check.Results(locFail);
            testCase.verifyEqual(failedCheck.Name, mag.imap.health.Power.PropertyToHumanReadableConversion(FailLow.Property), "Failed check name should match expectation.");
        end

        % Test that checks are borderline when value is higher than warning
        % high.
        function warningHigh(testCase, BorderlineHigh)

            % Set up.
            pwr = testCase.createTestPowerHK();
            pwr.Data.(BorderlineHigh.Column)(1) = BorderlineHigh.Value;

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locBorderline = [check.Results.Status] == mag.health.Status.Borderline;
            testCase.assertEqual(nnz(locBorderline), 1, "Only 1 check should be borderline.");

            borderlineCheck = check.Results(locBorderline);
            testCase.verifyEqual(borderlineCheck.Name, mag.imap.health.Power.PropertyToHumanReadableConversion(BorderlineHigh.Property), "Borderline check name should match expectation.");
        end

        % Test that checks are borderline when value is lower than warning
        % low.
        function warningLow(testCase, BorderlineLow)

            % Set up.
            pwr = testCase.createTestPowerHK();
            pwr.Data.(BorderlineLow.Column)(1) = BorderlineLow.Value;

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locBorderline = [check.Results.Status] == mag.health.Status.Borderline;
            testCase.assertEqual(nnz(locBorderline), 1, "Only 1 check should be borderline.");

            borderlineCheck = check.Results(locBorderline);
            testCase.verifyEqual(borderlineCheck.Name, mag.imap.health.Power.PropertyToHumanReadableConversion(BorderlineLow.Property), "Borderline check name should match expectation.");
        end

        % Test that checks fail on any saturation flag.
        function saturationFlag(testCase, SaturationFlag)

            % Set up.
            pwr = testCase.createTestPowerHK();
            pwr.Data.(SaturationFlag.Property)(1) = true;

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locFail = [check.Results.Status] == mag.health.Status.Fail;
            testCase.assertEqual(nnz(locFail), 1, "Only 1 check should fail.");

            failedCheck = check.Results(locFail);
            testCase.verifySubstring(failedCheck.Description, SaturationFlag.Name, "Failed check description should match expectation.");
        end

        % Test that checks fail on missed ITF frames.
        function missedITFFrame(testCase)

            % Set up.
            pwr = testCase.createTestPowerHK();
            pwr.Data.MAGITFMISSCNT(1) = 2;

            instrument = mag.imap.Instrument(HK = pwr);
            check = mag.imap.health.Power();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locFail = [check.Results.Status] == mag.health.Status.Fail;
            testCase.assertEqual(nnz(locFail), 1, "Only 1 check should fail.");

            failedCheck = check.Results(locFail);
            testCase.verifySubstring(failedCheck.Description, "2", "Failed check description should match expectation.");
        end
    end

    methods (Static, Access = private)

        function pwr = createTestPowerHK()

            N = numel(mag.test.DataTestUtilities.Time);
            onesArray = ones(N, 1);

            pwrTT = timetable(mag.test.DataTestUtilities.Time, ...
                25 * onesArray, ...
                21 * onesArray, ...
                22 * onesArray, ...
                1.52 * onesArray, ...
                420 * onesArray, ...
                1.83 * onesArray, ...
                30 * onesArray, ...
                3.36 * onesArray, ...
                120 * onesArray, ...
                2.55 * onesArray, ...
                100 * onesArray, ...
                9.5 * onesArray, ...
                200 * onesArray, ...
                -9.5 * onesArray, ...
                150 * onesArray, ...
                2.35 * onesArray, ...
                false(N, 1), ...
                false(N, 1), ...
                false(N, 1), ...
                false(N, 1), ...
                false(N, 1), ...
                false(N, 1), ...
                0 * onesArray, ...
                VariableNames = ["ICU_TEMP", "FOB_TEMP", "FIB_TEMP", ...
                "P1V5V", "P1V5I", "P1V8V", "P1V8I", "P3V3V", "P3V3I", "P2V5V", "P2V5I", "P8V", "P8VI", "N8V", "N8VI", "P2V4V", ...
                "MAGOSATFLAG" + ["X", "Y", "Z"], "MAGISATFLAG" + ["X", "Y", "Z"], "MAGITFMISSCNT"]);

            pwr = mag.imap.hk.Power(pwrTT, mag.meta.HK(Typ = "Power"));
        end
    end
end
