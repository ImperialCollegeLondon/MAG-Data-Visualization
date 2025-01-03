classdef tPSD < MAGControllerTestCase
% TPSD Unit tests for "mag.app.control.PSD" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();
            psd = mag.app.control.PSD(@mag.bart.view.PSD);

            % Exercise.
            psd.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(psd.StartDatePicker, "Start date picker should not be empty.");
            testCase.assertNotEmpty(psd.StartTimeField, "Start time field should not be empty.");
            testCase.assertNotEmpty(psd.DurationSpinner, "Duration spinner should not be empty.");

            testCase.verifyEqual(psd.StartDatePicker.Layout, matlab.ui.layout.GridLayoutOptions(Row = 1, Column = 2), ...
                "Start date picker layout should match expectation.");

            testCase.verifyEqual(psd.StartTimeField.Placeholder, 'HH:mm:ss.SSS', "Start time field placeholder should match expectation.");
            testCase.verifyEqual(psd.StartTimeField.Layout, matlab.ui.layout.GridLayoutOptions(Row = 1, Column = 3), ...
                "Start time field layout should match expectation.");

            testCase.verifyEqual(psd.DurationSpinner.Value, 1, "Duration spinner value should match expectation.");
            testCase.verifyEqual(psd.DurationSpinner.Limits, [0, Inf], "Duration spinner limits should match expectation.");
            testCase.verifyEqual(psd.DurationSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 2, Column = [2, 3]), ...
                "Duration spinner layout should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.instantiate(panel);

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyTrue(ismissing(command.NamedArguments.Start), """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "StartDate" is modified.
        function getVisualizeCommand_modifiedStartDate(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.instantiate(panel);

            psd.StartDatePicker.Value = datetime("today");
            psd.StartTimeField.Value = "10:30";

            expectedStartDate = datetime("today") + duration(10, 30, 0);
            expectedStartDate.Format = mag.time.Constant.Format;
            expectedStartDate.TimeZone = mag.time.Constant.TimeZone;

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, expectedStartDate, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "Duration" is modified.
        function getVisualizeCommand_modifiedDuration(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.instantiate(panel);

            psd.DurationSpinner.Value = 2.15;

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyTrue(ismissing(command.NamedArguments.Start), """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(2.15), """Duration"" should match expectation.");
        end
    end
end
