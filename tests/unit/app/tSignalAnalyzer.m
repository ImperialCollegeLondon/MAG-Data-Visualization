classdef tSignalAnalyzer < mag.test.case.ViewControllerTestCase
% TSIGNALANALYZER Unit tests for "mag.app.control.SignalAnalyzer" class.

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
            signalAnalyzer = mag.app.control.SignalAnalyzer(inputSignals);

            % Exercise.
            signalAnalyzer.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(signalAnalyzer.InputDropDown, "Input drop down should not be empty.");
            testCase.assertNotEmpty(signalAnalyzer.SignalDropDown, "Signal drop down should not be empty.");

            testCase.verifyEqual(string(signalAnalyzer.InputDropDown.Items), inputSignals, "Input drop down values should match expectation.");
            testCase.verifyEqual(string(signalAnalyzer.SignalDropDown.Items), ["X", "Y", "Z"], "Signal drop down values should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase, Sensor, Axis)

            % Set up.
            panel = testCase.createTestPanel();

            signalAnalyzer = mag.app.control.SignalAnalyzer(["Outboard", "Inboard"]);
            signalAnalyzer.instantiate(panel);

            signalAnalyzer.InputDropDown.Value = Sensor;
            signalAnalyzer.SignalDropDown.Value = Axis;

            results = mag.imap.Instrument();
            results.Science(1) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FOB"));
            results.Science(2) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FIB"));

            expectedData = timetable(results.(Sensor).Time - results.(Sensor).Time(1), results.(Sensor).(Axis), VariableNames = compose("%s_%s", Sensor, Axis));

            % Exercise.
            command = signalAnalyzer.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.Functional, @signalAnalyzer, "Visualize command function should match expectation.");

            testCase.verifyEqual(command.PositionalArguments, {expectedData}, "Visualize command positional arguments should match expectation.");
            testCase.verifyEmpty(command.NamedArguments, "Visualize command named arguments shouldbe empty.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand_nonFiniteData(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            signalAnalyzer = mag.app.control.SignalAnalyzer(["Outboard", "Inboard"]);
            signalAnalyzer.instantiate(panel);

            results = mag.imap.Instrument();
            results.Science(1) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FOB"));
            results.Science(2) = mag.Science(mag.test.DataTestUtilities.getScienceTimetable(), mag.meta.Science(Sensor = "FIB"));

            results.Outboard.Data{[2, 5], "x"} = missing();

            expectedData = timetable(results.Outboard.Time - results.Outboard.Time(1), results.Outboard.X, VariableNames = "Outboard_X");
            expectedData = expectedData([1, 3:4, 6:end], :);

            % Exercise.
            command = testCase.verifyWarning(@() signalAnalyzer.getVisualizeCommand(results), "mag:app:NonFiniteData", ...
                "Warning should be issued when removing non-finite data.");

            % Verify.
            testCase.verifyEqual(command.Functional, @signalAnalyzer, "Visualize command function should match expectation.");

            testCase.verifyEqual(command.PositionalArguments, {expectedData}, "Visualize command positional arguments should match expectation.");
            testCase.verifyEmpty(command.NamedArguments, "Visualize command named arguments shouldbe empty.");
        end

        % Test that "getVisualizeCommand" throws error when there is no
        % data to plot.
        function getVisualizeCommand_noData(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            signalAnalyzer = mag.app.control.SignalAnalyzer(["Input1", "Input2"]);
            signalAnalyzer.instantiate(panel);

            results = mag.bart.Instrument();

            % Exercise and verify.
            testCase.verifyError(@() signalAnalyzer.getVisualizeCommand(results), "mag:app:EmptySignal", ...
                "Error should be thrown when there is no data to plot.");
        end
    end
end
