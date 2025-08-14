classdef tPSD < mag.test.case.ViewControllerTestCase & matlab.uitest.TestCase
% TPSD Unit tests for "mag.app.control.PSD" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.Model = model;

            % Exercise.
            psd.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(psd.StartTimeSlider, "Start date slider should not be empty.");
            testCase.assertNotEmpty(psd.DurationSpinner, "Duration spinner should not be empty.");

            testCase.verifyEqual(psd.StartTimeSlider.Layout, matlab.ui.layout.GridLayoutOptions(Row = 1, Column = [2, 3]), ...
                "Start date picker layout should match expectation.");

            testCase.verifyEqual(psd.DurationSpinner.Value, 1, "Duration spinner value should match expectation.");
            testCase.verifyEqual(psd.DurationSpinner.Limits, [0, Inf], "Duration spinner limits should match expectation.");
            testCase.verifyEqual(psd.DurationSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 2, Column = [2, 3]), ...
                "Duration spinner layout should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.Model = model;
            psd.instantiate(panel);

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, psd.StartTimeSlider.SelectedTime, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "StartDate" is modified.
        function getVisualizeCommand_modifiedStartDate(testCase)

            % Set up.
            panel = testCase.createTestPanel(VisibleOverride = "on");

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.Model = model;
            psd.instantiate(panel);

            testCase.drag(psd.StartTimeSlider.Slider, 0, 50);

            expectedStartDate = psd.StartTimeSlider.Limits(1) + (range(psd.StartTimeSlider.Limits) * psd.StartTimeSlider.Slider.Value / range(psd.StartTimeSlider.SliderLimits));
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

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.bart.view.PSD);
            psd.Model = model;
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

            testCase.verifyEqual(command.NamedArguments.Start, psd.StartTimeSlider.SelectedTime, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(2.15), """Duration"" should match expectation.");
        end
    end
end
