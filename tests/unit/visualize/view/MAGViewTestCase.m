classdef MAGViewTestCase < mag.test.GraphicsTestCase & matlab.mock.TestCase
% MAGVIEWTESTCASE Base class for all MAG view tests.

    methods (Access = protected)

        function expectedOutput = verifyInputsAndAssignOutput(testCase, expectedOutput, expectedInputs, actualInputs)
        % VERIFYINPUTSANDASSIGNOUTPUT Utility method to verify input values
        % are as expected, and assign a pre-defined output value.

            testCase.assertNumElements(actualInputs, numel(expectedInputs), "Number of inputs should be as expected.");

            for i = 1:numel(expectedInputs)
                testCase.verifyEqual(expectedInputs{i}, actualInputs{i}, compose("Input #%i should match expectation.", i));
            end
        end

        function expectedOutput = verifyNameValuesAndAssignOutput(testCase, expectedOutput, expectedNameValues, actualInputs)
        % VERIFYNAMEVALUESANDASSIGNOUTPUT Utility method to verify subset
        % of name-values are as expected, and assign a pre-defined output
        % value.

            assert(mod(numel(expectedNameValues), 2) == 0, "Expected name-value inputs must be even.");

            testCase.assertGreaterThanOrEqual(numel(actualInputs), numel(expectedNameValues), "Expected inputs should exist.");

            for i = 1:(0.5 * numel(expectedNameValues))

                nvp = expectedNameValues((2 * i - 1):(2 * i));

                testCase.verifyThat(matlab.unittest.constraints.AnyCellOf(actualInputs), matlab.unittest.constraints.IsEqualTo(nvp{1}), "Name should exist.");
                testCase.verifyThat(matlab.unittest.constraints.AnyCellOf(actualInputs), matlab.unittest.constraints.IsEqualTo(nvp{2}), "Value should exist.");

                locNameMatch = cellfun(@(x) isequal(x, nvp{1}), actualInputs);
                locValueMatch = cellfun(@(x) isequal(x, nvp{2}), actualInputs);

                idxMatches = abs(find(locNameMatch) - find(locValueMatch)');
                testCase.verifyThat(matlab.unittest.constraints.AnyElementOf(idxMatches), matlab.unittest.constraints.IsEqualTo(1), "Name-value pair should be consecutive.");
            end
        end
    end

    methods (Static, Access = protected)

        function instrument = createTestInstrument(options)

            arguments
                options.AddHK (1, 1) logical = false
            end

            % Create instrument meta data.
            metaInstrument = mag.meta.Instrument(ASW = "5.01", BSW = "0.02", GSE = "10.5.4", Model = "FM", Timestamp = datetime("now", TimeZone = "UTC"));

            % Create science data.
            setup1 = mag.meta.Setup(Can = "None", FEE = "FEE2", Harness = "Some cable", Model = "EM4");
            setup2 = mag.meta.Setup(Can = "Some", FEE = "FEE4", Harness = "Other cable", Model = "LM2");

            metaScience1 = mag.meta.Science(Primary = false, Mode = "Burst", DataFrequency = 8, PacketFrequency = 4, ...
                Sensor = "FOB", Setup = setup1, Timestamp = mag.test.DataTestUtilities.Time(1));
            metaScience2 = mag.meta.Science(Primary = true, Mode = "Burst", DataFrequency = 64, PacketFrequency = 4, ...
                Sensor = "FIB", Setup = setup2);

            science1 = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), metaScience1);
            science2 = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), metaScience2);

            % Assemble instrument data.
            instrument = mag.imap.Instrument(Science = [science1, science2], MetaData = metaInstrument);

            % Create HK.
            if options.AddHK

                pwrHK = mag.imap.hk.Power(mag.test.DataTestUtilities.getPowerTimetable(), mag.meta.HK(Type = "PW", Timestamp = datetime("now", TimeZone = "UTC")));
                procstatHK = mag.imap.hk.Processor(mag.test.DataTestUtilities.getProcessorTimetable(), mag.meta.HK(Type = "PROCSTAT", Timestamp = datetime("now", TimeZone = "UTC")));

                instrument.HK = [pwrHK, procstatHK];
            end
        end
    end
end
