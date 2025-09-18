classdef tSID15 < matlab.unittest.TestCase
% TSID15 Unit tests for "mag.imap.health.SID15" class.

    properties (TestParameter)
        ActivationTries = { ...
            struct(Property = "FOBAttempts", Column = "ISV_FOB_ACTTRIES", Name = "FOB Activation"), ...
            struct(Property = "FIBAttempts", Column = "ISV_FIB_ACTTRIES", Name = "FIB Activation")}
    end

    methods (Test)

        % Test that valid SID15 values pass all checks.
        function allChecksPass(testCase)

            % Set up.
            sid15 = testCase.createTestSID15HK();

            instrument = mag.imap.Instrument(HK = sid15);
            check = mag.imap.health.SID15();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            testCase.verifyEqual(matlab.unittest.constraints.EveryElementOf([check.Results.Status]), mag.health.Status.Pass, "All checks should pass.");
        end

        % Test that no checks are run if no SID15 HK is available.
        function noSID15HK(testCase)

            % Set up.
            instrument = mag.imap.Instrument();
            check = mag.imap.health.SID15();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertEmpty(check.Results, "Results should not have been populated.");
        end

        % Test that checks fail on sensor activation failure.
        function activationTries_fail(testCase, ActivationTries)

            % Set up.
            sid15 = testCase.createTestSID15HK();
            sid15.Data.(ActivationTries.Column)(1) = 14;

            instrument = mag.imap.Instrument(HK = sid15);
            check = mag.imap.health.SID15();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locFail = [check.Results.Status] == mag.health.Status.Fail;
            testCase.assertEqual(nnz(locFail), 1, "Only 1 check should fail.");

            failedCheck = check.Results(locFail);
            testCase.verifySubstring(failedCheck.Name, ActivationTries.Name, "Failed check name should match expectation.");
        end

        % Test that checks are borderline on many sensor activations.
        function activationTries_borderline(testCase, ActivationTries)

            % Set up.
            sid15 = testCase.createTestSID15HK();
            sid15.Data.(ActivationTries.Column)(1) = 10;

            instrument = mag.imap.Instrument(HK = sid15);
            check = mag.imap.health.SID15();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locBorderline = [check.Results.Status] == mag.health.Status.Borderline;
            testCase.assertEqual(nnz(locBorderline), 1, "Only 1 check should be borderline.");

            borderlineCheck = check.Results(locBorderline);
            testCase.verifySubstring(borderlineCheck.Name, ActivationTries.Name, "Borderline check name should match expectation.");
        end
    end

    methods (Static, Access = private)

        function sid15 = createTestSID15HK()

            N = numel(mag.test.DataTestUtilities.Time);
            onesArray = ones(N, 1);

            sid15TT = timetable(mag.test.DataTestUtilities.Time, ...
                5 * onesArray, ...
                5 * onesArray, ...
                VariableNames = ["ISV_FOB_ACTTRIES", "ISV_FIB_ACTTRIES"]);

            sid15 = mag.imap.hk.SID15(sid15TT, mag.meta.HK(Typ = "SID15"));
        end
    end
end
