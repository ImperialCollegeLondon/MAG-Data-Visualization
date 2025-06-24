classdef tCPT < mag.test.ViewControllerTestCase & matlab.uitest.TestCase
% TCPT Unit tests for "mag.app.imap.control.CPT" class.

    properties (TestParameter)
        PatternField = {"PrimaryModePatternField", "SecondaryModePatternField", "RangePatternField"}
    end

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();
            cpt = mag.app.imap.control.CPT();

            % Exercise.
            cpt.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(cpt.StartFilterSpinner, "Start filter spinner should not be empty.");
            testCase.assertNotEmpty(cpt.PrimaryModePatternField, "Primary mode pattern field should not be empty.");
            testCase.assertNotEmpty(cpt.SecondaryModePatternField, "Secondary mode pattern field should not be empty.");
            testCase.assertNotEmpty(cpt.RangePatternField, "Range pattern field should not be empty.");

            testCase.verifyEqual(cpt.StartFilterSpinner.Layout, matlab.ui.layout.GridLayoutOptions(Row = 1, Column = [2, 3]), ...
                "Start filter spinner layout should match expectation.");

            testCase.verifyEqual(cpt.PrimaryModePatternField.Value, '2, 64, 2, 4, 64, 4, 4, 128', "Primary mode pattern field value should match expectation.");
            testCase.verifyEqual(cpt.PrimaryModePatternField.Layout, matlab.ui.layout.GridLayoutOptions(Row = 2, Column = [2, 3]), ...
                "Primary mode pattern field layout should match expectation.");

            testCase.verifyEqual(cpt.SecondaryModePatternField.Value, '2, 8, 2, 1, 64, 1, 4, 128', "Secondary mode pattern field value should match expectation.");
            testCase.verifyEqual(cpt.SecondaryModePatternField.Layout, matlab.ui.layout.GridLayoutOptions(Row = 3, Column = [2, 3]), ...
                "Secondary mode pattern field layout should match expectation.");

            testCase.verifyEqual(cpt.RangePatternField.Value, '3, 2, 1, 0', "Range pattern field value should match expectation.");
            testCase.verifyEqual(cpt.RangePatternField.Layout, matlab.ui.layout.GridLayoutOptions(Row = 4, Column = [2, 3]), ...
                "Range pattern field layout should match expectation.");
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            cpt = mag.app.imap.control.CPT();
            cpt.instantiate(panel);

            results = mag.imap.Analysis();

            % Exercise.
            command = cpt.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            for f = ["Filter", "PrimaryModePattern", "SecondaryModePattern", "RangePattern"]
                testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField(f), compose("""%s"" should be a named argument.", f));
            end

            testCase.verifyEqual(command.NamedArguments.Filter, minutes(1), """Filter"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.PrimaryModePattern, [2, 64, 2, 4, 64, 4, 4, 128], """PrimaryModePattern"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.SecondaryModePattern, [2, 8, 2, 1, 64, 1, 4, 128], """SecondaryModePattern"" should match expectation.");
            testCase.verifyEqual(command.NamedArguments.RangePattern, [3, 2, 1, 0], """RangePattern"" should match expectation.");
        end

        % Test that error is thrown if patterns do not match expected
        % format.
        function pattern_validFormat(testCase, PatternField)

            % Set up.
            panel = testCase.createTestPanel(VisibleOverride = "on");

            cpt = mag.app.imap.control.CPT();
            cpt.instantiate(panel);

            % Exercise and verify.
            testCase.type(cpt.(PatternField), "1, 2, 3");
        end

        % Test that alert is shown if patterns do not match expected
        % format.
        function pattern_invalidFormat(testCase, PatternField)

            % Set up.
            panel = testCase.createTestPanel(VisibleOverride = "on");

            cpt = mag.app.imap.control.CPT();
            cpt.instantiate(panel);

            % Exercise.
            testCase.type(cpt.(PatternField), "123 invalid");

            % Verify.
            testCase.dismissDialog("uialert", panel.Parent);
        end
    end
end
