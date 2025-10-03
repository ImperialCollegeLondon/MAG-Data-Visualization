classdef tProcessor < matlab.unittest.TestCase
% TPROCESSOR Unit tests for "mag.imap.health.Processor" class.

    properties (TestParameter)
        FailedCheck = { ...
            struct(Property = "SRAM_SINGBITERRCNT", Value = 2), ...
            struct(Property = "ITF_MSD_FR", Value = 2), ...
            struct(Property = "ITF_REJ_FR", Value = 2)}
    end

    methods (Test)

        % Test that valid processor values pass all checks.
        function allChecksPass(testCase)

            % Set up.
            procStat = testCase.createTestProcessorHK();

            instrument = mag.imap.Instrument(HK = procStat);
            check = mag.imap.health.Processor();

            testCase.assertTrue(check.isSupported(instrument), "Check should be supported for valid processor HK.");

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNumElements(check.Results, 3, "Results should have been populated.");

            testCase.verifyEqual(matlab.unittest.constraints.EveryElementOf([check.Results.Status]), mag.health.Status.Pass, "All checks should pass.");
        end

        % Test that checks are not supported if no HK is available.
        function noHK(testCase)

            % Set up.
            instrument = mag.imap.Instrument();
            check = mag.imap.health.Processor();

            % Exercise and verify.
            testCase.verifyFalse(check.isSupported(instrument), "Check should not be supported if no HK is available.");
        end

        % Test that checks are not supported if no processor HK is available.
        function noProcessorHK(testCase)

            % Set up.
            status = mag.imap.hk.Status(timetable(), mag.meta.HK(Type = "Status"));

            instrument = mag.imap.Instrument(HK = status);
            check = mag.imap.health.Processor();

            % Exercise and verify.
            testCase.verifyFalse(check.isSupported(instrument), "Check should not be supported if no processor HK is available.");
        end

        % Test that checks fail with expected values.
        function fail(testCase, FailedCheck)

            % Set up.
            procStat = testCase.createTestProcessorHK();
            procStat.Data.(FailedCheck.Property)(1) = FailedCheck.Value;

            instrument = mag.imap.Instrument(HK = procStat);
            check = mag.imap.health.Processor();

            % Exercise.
            check.run(instrument);

            % Verify.
            testCase.assertNotEmpty(check.Results, "Results should have been populated.");

            locFail = [check.Results.Status] == mag.health.Status.Fail;
            testCase.assertEqual(nnz(locFail), 1, "Only 1 check should fail.");

            failedCheck = check.Results(locFail);
            testCase.verifySubstring(failedCheck.Description, num2str(FailedCheck.Value), "Failed check description should match expectation.");
        end
    end

    methods (Static, Access = private)

        function procStat = createTestProcessorHK()

            N = numel(mag.test.DataTestUtilities.Time);
            onesArray = ones(N, 1);

            procStatTT = timetable(mag.test.DataTestUtilities.Time, ...
                0 * onesArray, ...
                0 * onesArray, ...
                0 * onesArray, ...
                0 * onesArray, ...
                0 * onesArray, ...
                VariableNames = ["SRAM_SINGBITERRCNT", "ITF_MSD_FR", "ITF_REJ_FR", ...
                "OBNQ_NUM_MSG", "IBNQ_NUM_MSG"]);

            procStat = mag.imap.hk.Processor(procStatTT, mag.meta.HK(Type = "Processor"));
        end
    end
end
