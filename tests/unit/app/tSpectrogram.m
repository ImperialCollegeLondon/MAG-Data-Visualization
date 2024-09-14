classdef tSpectrogram < MAGControllerTestCase
% TSPECTROGRAM Unit tests for "mag.app.imap.controlSpectrogram" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();
            spectrogram = mag.app.imap.control.Spectrogram();

            % Exercise.
            spectrogram.instantiate(panel);

            % Verify.
            testCase.verifyStartEndDateButtons(spectrogram, StartDateRow = 1, EndDateRow = 2);

            testCase.assertNotEmpty(spectrogram.FrequencyPointsSpinner, "Frequency points spinner should not be empty.");
            testCase.assertNotEmpty(spectrogram.OverlapSpinner, "Overlap spinner should not be empty.");
            testCase.assertNotEmpty(spectrogram.WindowSpinner, "Window spinner should not be empty.");

            testCase.verifyEqual(spectrogram.FrequencyPointsSpinner.Value, 256, "Frequency points spinner value should match expectation.");
            testCase.verifyEqual(spectrogram.FrequencyPointsSpinner.Step, 1, "Frequency points spinner step should match expectation.");
            testCase.verifyEqual(spectrogram.FrequencyPointsSpinner.Limits, [0, Inf], "Frequency points spinner limits should match expectation.");
            testCase.verifyEqual(spectrogram.FrequencyPointsSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 3, Column = [2, 3]), ...
                "Frequency points spinner layout should match expectation.");

            testCase.verifyEmpty(spectrogram.OverlapSpinner.Value, "Overlap spinner value should be empty.");
            testCase.verifyTrue(spectrogram.OverlapSpinner.AllowEmpty, "Overlap spinner empty allowance should be true.");
            testCase.verifyEqual(spectrogram.OverlapSpinner.ValueDisplayFormat, '%.2f', "Overlap spinner value display format should match expectation.");
            testCase.verifyEqual(spectrogram.OverlapSpinner.Step, 0.1, "Overlap spinner step should match expectation.");
            testCase.verifyEqual(spectrogram.OverlapSpinner.Limits, [0, 1], "Overlap spinner limits should match expectation.");
            testCase.verifyFalse(spectrogram.OverlapSpinner.LowerLimitInclusive, "Overlap spinner lower limit inclusion should be false.");
            testCase.verifyEqual(spectrogram.OverlapSpinner.Placeholder, char(testCase.DynamicPlaceholder), "Overlap spinner placeholder should match expectation.");
            testCase.verifyEqual(spectrogram.OverlapSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 4, Column = [2, 3]), ...
                "Overlap spinner layout should match expectation.");

            testCase.verifyEmpty(spectrogram.WindowSpinner.Value, "Window spinner value should be empty.");
            testCase.verifyTrue(spectrogram.WindowSpinner.AllowEmpty, "Window spinner empty allowance should be true.");
            testCase.verifyEqual(spectrogram.WindowSpinner.Step, 1, "Window spinner step should match expectation.");
            testCase.verifyEqual(spectrogram.WindowSpinner.Limits, [0, Inf], "Window spinner limits should match expectation.");
            testCase.verifyFalse(spectrogram.WindowSpinner.LowerLimitInclusive, "Window spinner lower limit inclusion should be false.");
            testCase.verifyEqual(spectrogram.WindowSpinner.Placeholder, char(testCase.DynamicPlaceholder), "Window spinner placeholder should match expectation.");
            testCase.verifyEqual(spectrogram.WindowSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 5, Column = [2, 3]), ...
                "Window spinner layout should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            spectrogram = mag.app.imap.control.Spectrogram();
            spectrogram.instantiate(panel);

            results = mag.Instrument();

            % Exercise.
            command = spectrogram.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["FrequencyPoints", "Overlap", "Window"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.FrequencyPoints, 256, """FrequencyPoints"" should match expectation.");
            testCase.verifyTrue(ismissing(command.NamedArguments.Overlap), """Overlap"" should match expectation.");
            testCase.verifyTrue(ismissing(command.NamedArguments.Window), """Window"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "Overlap" is modified.
        function getVisualizeCommand_modifiedOverlap(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            spectrogram = mag.app.imap.control.Spectrogram();
            spectrogram.instantiate(panel);

            spectrogram.OverlapSpinner.Value = 0.5;

            results = mag.Instrument();

            % Exercise.
            command = spectrogram.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["FrequencyPoints", "Overlap", "Window"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.FrequencyPoints, 256, """FrequencyPoints"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Overlap, 0.5, """Overlap"" should match expectation.");
            testCase.verifyTrue(ismissing(command.NamedArguments.Window), """Window"" should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % "Window" is modified.
        function getVisualizeCommand_modifiedWindow(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            spectrogram = mag.app.imap.control.Spectrogram();
            spectrogram.instantiate(panel);

            spectrogram.WindowSpinner.Value = 25;

            results = mag.Instrument();

            % Exercise.
            command = spectrogram.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["FrequencyPoints", "Overlap", "Window"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.FrequencyPoints, 256, """FrequencyPoints"" should match expectation.");
            testCase.verifyTrue(ismissing(command.NamedArguments.Overlap), """Overlap"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.Window, 25, """Window"" should match expectation.");
        end
    end
end
