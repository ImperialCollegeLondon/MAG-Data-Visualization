classdef tIALiRT < matlab.mock.TestCase
% TIALIRT Unit tests for "mag.imap.IALiRT" class.

    properties (TestParameter)
        SignalMethod = {"resample", "downsample"}
    end

    methods (Test)

        % Test that "HasData" property returns "true" when data is present.
        function hasData(testCase)

            % Set up.
            primary = mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1), mag.meta.Science());
            secondary = mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1), mag.meta.Science());

            iALiRT = mag.imap.IALiRT(Science = [primary, secondary]);

            % Exercise and verify.
            testCase.verifyTrue(iALiRT.HasData, """HasData"" property should be ""true"".");
        end

        % Test that "HasData" property returns "false" when primary has
        % no data.
        function hasData_primaryNoData(testCase)

            % Set up.
            primary = mag.Science(timetable.empty(), mag.meta.Science());
            secondary = mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1), mag.meta.Science());

            iALiRT = mag.imap.IALiRT(Science = [primary, secondary]);

            % Exercise and verify.
            testCase.verifyFalse(iALiRT.HasData, """HasData"" property should be ""false"".");
        end

        % Test that "HasData" property returns "false" when secondary has
        % no data.
        function hasData_secondaryNoData(testCase)

            % Set up.
            primary = mag.Science(timetable(datetime("now", TimeZone = "UTC"), 1), mag.meta.Science());
            secondary = mag.Science(timetable.empty(), mag.meta.Science());

            iALiRT = mag.imap.IALiRT(Science = [primary, secondary]);

            % Exercise and verify.
            testCase.verifyFalse(iALiRT.HasData, """HasData"" property should be ""false"".");
        end

        % Test that "crop" method calls method of underlying science data.
        function cropMethod(testCase)

            % Set up.
            [iALiRT, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            timeFilter1 = timerange(datetime("-Inf", TimeZone = "UTC"), datetime("now", TimeZone = "UTC"));
            timeFilter2 = timerange(datetime("now", TimeZone = "UTC"), datetime("Inf", TimeZone = "UTC"));

            % Exercise.
            iALiRT.crop(timeFilter1, timeFilter2);

            % Verify.
            testCase.verifyCalled(primaryBehavior.crop(timeFilter1), "Primary data should be cropped with primary filter.");
            testCase.verifyCalled(secondaryBehavior.crop(timeFilter2), "Secondary data should be cropped with secondary filter.");
        end

        % Test that signal modification methods call method of underlying
        % science data.
        function signalMethods(testCase, SignalMethod)

            % Set up.
            [iALiRT, primaryBehavior, secondaryBehavior] = testCase.createTestData();

            targetFrequency = 1 / 120;

            % Exercise.
            feval(SignalMethod, iALiRT, targetFrequency);

            % Verify.
            testCase.verifyCalled(primaryBehavior.(SignalMethod)(targetFrequency), "Primary data signal modification method should be called.");
            testCase.verifyCalled(secondaryBehavior.(SignalMethod)(targetFrequency), "Secondary data signal modification method should be called.");
        end

        % Test that "copy" method performs a deep copy of all data.
        function copyMethod(testCase)

            % Set up.
            iALiRT = testCase.createTestData();

            % Exercise.
            copiedIALiRT = iALiRT.copy();

            % Verify.
            testCase.verifyEqual(iALiRT, copiedIALiRT, "Copied data should be equal.");

            testCase.verifyNotSameHandle(iALiRT, copiedIALiRT, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(iALiRT.Primary, copiedIALiRT.Primary, "Copied data should be different instance.");
            testCase.verifyNotSameHandle(iALiRT.Secondary, copiedIALiRT.Secondary, "Copied data should be different instance.");
        end
    end

    methods (Access = private)

        function [iALiRT, primaryBehavior, secondaryBehavior] = createTestData(testCase)

            scienceTT = mag.test.DataTestUtilities.getScienceTimetable();

            [primary, primaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {scienceTT, mag.meta.Science(Primary = true, Sensor = "FOB")}, Strict = true);
            [secondary, secondaryBehavior] = testCase.createMock(?mag.Science, ConstructorInputs = {scienceTT, mag.meta.Science(Sensor = "FIB")}, Strict = true);

            iALiRT = mag.imap.IALiRT(Science = [primary, secondary]);
        end
    end
end
