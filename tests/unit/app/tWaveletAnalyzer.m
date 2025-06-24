classdef tWaveletAnalyzer < mag.test.ViewControllerTestCase
% TWAVELETANALYZER Unit tests for "mag.app.control.WaveletAnalyzer" class.

    properties (TestParameter)
        Sensor = {"Outboard", "Inboard"}
        Axis = {"X", "Y", "Z"}
    end

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            inputSignals = ["A", "B"];

            panel = testCase.createTestPanel();
            waveletAnalyzer = mag.app.control.WaveletAnalyzer(inputSignals);

            % Exercise.
            waveletAnalyzer.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(waveletAnalyzer.AppDropDown, "App drop down should not be empty.");
            testCase.assertNotEmpty(waveletAnalyzer.InputDropDown, "Input drop down should not be empty.");
            testCase.assertNotEmpty(waveletAnalyzer.SignalDropDown, "Signal drop down should not be empty.");

            testCase.verifyEqual(string(waveletAnalyzer.AppDropDown.Items), ["Signal Analyzer", "Time-Frequency Analyzer"], "App drop down values should match expectation.");
            testCase.verifyEqual(string(waveletAnalyzer.InputDropDown.Items), inputSignals, "Input drop down values should match expectation.");
            testCase.verifyEqual(string(waveletAnalyzer.SignalDropDown.Items), ["X", "Y", "Z"], "Signal drop down values should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command for
        % Wavelet Signal Analyzer.
        function getVisualizeCommand_waveletSignalAnalyzer(testCase, Sensor, Axis)

            % Set up.
            panel = testCase.createTestPanel();

            waveletAnalyzer = mag.app.control.WaveletAnalyzer(["Outboard", "Inboard"]);
            waveletAnalyzer.instantiate(panel);

            waveletAnalyzer.AppDropDown.Value = "Signal Analyzer";
            waveletAnalyzer.InputDropDown.Value = Sensor;
            waveletAnalyzer.SignalDropDown.Value = Axis;

            results = mag.imap.Instrument();
            results.Science(1) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FOB"));
            results.Science(2) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FIB"));

            expectedData = results.(Sensor).(Axis);

            % Exercise.
            command = waveletAnalyzer.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.Functional, @waveletSignalAnalyzer, "Visualize command function should match expectation.");

            testCase.verifyEqual(command.PositionalArguments, {expectedData}, "Visualize command positional arguments should match expectation.");
            testCase.verifyEmpty(command.NamedArguments, "Visualize command named arguments shouldbe empty.");
        end

        % Test that "getVisualizeCommand" returns expected command for
        % Wavelet Time Frequency Analyzer.
        function getVisualizeCommand_waveletTimeFrequencyAnalyzer(testCase, Sensor, Axis)

            % Set up.
            panel = testCase.createTestPanel();

            waveletAnalyzer = mag.app.control.WaveletAnalyzer(["Outboard", "Inboard"]);
            waveletAnalyzer.instantiate(panel);

            waveletAnalyzer.AppDropDown.Value = "Time-Frequency Analyzer";
            waveletAnalyzer.InputDropDown.Value = Sensor;
            waveletAnalyzer.SignalDropDown.Value = Axis;

            results = mag.imap.Instrument();
            results.Science(1) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FOB"));
            results.Science(2) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FIB"));

            expectedData = timetable(results.(Sensor).Time - results.(Sensor).Time(1), results.(Sensor).(Axis), VariableNames = compose("%s_%s", Sensor, Axis));

            % Exercise.
            command = waveletAnalyzer.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.Functional, @waveletTimeFrequencyAnalyzer, "Visualize command function should match expectation.");

            testCase.verifyEqual(command.PositionalArguments, {expectedData}, "Visualize command positional arguments should match expectation.");
            testCase.verifyEmpty(command.NamedArguments, "Visualize command named arguments shouldbe empty.");
        end

        % Test that "getVisualizeCommand" throws error when there is no
        % data to plot.
        function getVisualizeCommand_noData(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            waveletAnalyzer = mag.app.control.WaveletAnalyzer(["Input1", "Input2"]);
            waveletAnalyzer.instantiate(panel);

            results = mag.bart.Instrument();

            % Exercise and verify.
            testCase.verifyError(@() waveletAnalyzer.getVisualizeCommand(results), "mag:app:EmptySignal", ...
                "Error should be thrown when there is no data to plot.");
        end
    end
end
