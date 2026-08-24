classdef tPSD < mag.test.case.ViewControllerTestCase & matlab.uitest.TestCase
% TPSD Unit tests for "mag.app.control.PSD" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
            psd.Model = model;

            % Exercise.
            psd.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(psd.StartTimeSlider, "Start date slider should not be empty.");
            testCase.assertNotEmpty(psd.DurationSpinner, "Duration spinner should not be empty.");
            testCase.assertNotEmpty(psd.NoiseThresholdDropDown, "Noise threshold dropdown should not be empty.");
            testCase.assertNotEmpty(psd.SyncYAxesCheckBox, "Sync y-axes checkbox should not be empty.");

            testCase.verifyEqual(psd.StartTimeSlider.Layout, matlab.ui.layout.GridLayoutOptions(Row = 1, Column = [2, 3]), ...
                "Start date picker layout should match expectation.");

            testCase.verifyEqual(psd.DurationSpinner.Value, 1, "Duration spinner value should match expectation.");
            testCase.verifyEqual(psd.DurationSpinner.Limits, [0, Inf], "Duration spinner limits should match expectation.");
            testCase.verifyEqual(psd.DurationSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 2, Column = [2, 3]), ...
                "Duration spinner layout should match expectation.");

            testCase.verifyEqual(psd.NoiseThresholdDropDown.Value, mag.graphics.psd.NoiseThreshold.Default, "Noise threshold dropdown should match expectation.");
            testCase.verifyEqual(psd.SyncYAxesCheckBox.Value, false, "Sync y-axes checkbox value should match expectation.");
        end

        % Test that HelioSwarm model defaults to HelioSwarm noise threshold.
        function instantiate_helioSwarmDefaultNoiseThreshold(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.hs.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
            psd.Model = model;

            % Exercise.
            psd.instantiate(panel);

            % Verify.
            testCase.verifyEqual(psd.NoiseThresholdDropDown.Value, mag.graphics.psd.NoiseThreshold.HelioSwarm, ...
                "Noise threshold dropdown should default to HelioSwarm for HelioSwarm mission.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
            psd.Model = model;
            psd.instantiate(panel);

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration", "NoiseThreshold", "SyncYAxes"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, psd.StartTimeSlider.SelectedTime, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.NoiseThreshold, mag.graphics.psd.NoiseThreshold.Default, """NoiseThreshold"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.SyncYAxes, false, """Sync y-axes"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "StartDate" is modified.
        function getVisualizeCommand_modifiedStartDate(testCase)

            % Set up.
            panel = testCase.createTestPanel(VisibleOverride = "on");

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
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

            for f = ["Start", "Duration", "NoiseThreshold", "SyncYAxes"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, expectedStartDate, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.NoiseThreshold, mag.graphics.psd.NoiseThreshold.Default, """NoiseThreshold"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.SyncYAxes, false, """Sync y-axes"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "Duration" is modified.
        function getVisualizeCommand_modifiedDuration(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
            psd.Model = model;
            psd.instantiate(panel);

            psd.DurationSpinner.Value = 2.15;

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration", "NoiseThreshold", "SyncYAxes"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, psd.StartTimeSlider.SelectedTime, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(2.15), """Duration"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.NoiseThreshold, mag.graphics.psd.NoiseThreshold.Default, """NoiseThreshold"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.SyncYAxes, false, """Sync y-axes"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "NoiseThreshold" is modified.
        function getVisualizeCommand_noiseThreshold(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
            psd.Model = model;
            psd.instantiate(panel);

            psd.NoiseThresholdDropDown.Value = "HelioSwarm";

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration", "NoiseThreshold", "SyncYAxes"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, psd.StartTimeSlider.SelectedTime, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.NoiseThreshold, mag.graphics.psd.NoiseThreshold.HelioSwarm, """NoiseThreshold"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.SyncYAxes, false, """Sync y-axes"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "Sync y-axes" is modified.
        function getVisualizeCommand_syncYAxes(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            psd = mag.app.control.PSD(@mag.graphics.view.PSD);
            psd.Model = model;
            psd.instantiate(panel);

            psd.SyncYAxesCheckBox.Value = true;

            results = mag.bart.Instrument();

            % Exercise.
            command = psd.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Start", "Duration", "NoiseThreshold", "SyncYAxes"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Start, psd.StartTimeSlider.SelectedTime, """Start"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Duration, hours(1), """Duration"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.NoiseThreshold, mag.graphics.psd.NoiseThreshold.Default, """NoiseThreshold"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.SyncYAxes, true, """Sync y-axes"" should match expectation.");
        end
    end
end
