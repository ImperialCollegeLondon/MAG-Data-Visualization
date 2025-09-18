classdef tHealthManager < mag.test.case.ViewControllerTestCase
% THEALTHMANAGER Unit tests for "mag.app.manage.HealthManager" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();
            manager = mag.app.manage.HealthManager();

            % Exercise.
            manager.instantiate(panel);

            % Verify.
            testCase.assertNotEmpty(manager.HealthLayout, "Layout should not be empty.");
            testCase.assertNotEmpty(manager.SummaryLayout, "Summary should not be empty.");
            testCase.assertNotEmpty(manager.IndividualPanel, "Panel should not be empty.");
            testCase.assertNotEmpty(manager.NoteLabel, "Note should not be empty.");

            testCase.verifyEqual(manager.SummaryLayout.Visible, matlab.lang.OnOffSwitchState.off, "Summary should not be visible.");
            testCase.verifyEqual(manager.IndividualPanel.Visible, matlab.lang.OnOffSwitchState.off, "Panel should not be visible.");
            testCase.verifyEqual(manager.NoteLabel.Visible, matlab.lang.OnOffSwitchState.on, "Note should be visible.");
        end

        % Test that manager gets populated when analysis is loaded, and it
        % has health data.
        function populateOnHealthData(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            manager = mag.app.manage.HealthManager();
            manager.instantiate(panel);

            model = mag.app.imap.Model();
            manager.subscribe(model);

            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", "imap", "fob_only");

            testCase.assertEqual(manager.SummaryLayout.Visible, matlab.lang.OnOffSwitchState.off, "Summary should not be visible.");
            testCase.assertEqual(manager.IndividualPanel.Visible, matlab.lang.OnOffSwitchState.off, "Panel should not be visible.");
            testCase.assertEqual(manager.NoteLabel.Visible, matlab.lang.OnOffSwitchState.on, "Note should be visible.");

            % Exercise.
            model.analyze({"Location", location});

            % Verify.
            testCase.assertEqual(manager.SummaryLayout.Visible, matlab.lang.OnOffSwitchState.on, "Summary should be visible.");
            testCase.assertEqual(manager.IndividualPanel.Visible, matlab.lang.OnOffSwitchState.on, "Panel should be visible.");
            testCase.assertEqual(manager.NoteLabel.Visible, matlab.lang.OnOffSwitchState.off, "Note should not be visible.");

            expectedStatus = mag.health.Status.Fail;

            testCase.verifyEqual(manager.SummaryLamp.Color, hex2rgb(expectedStatus.Color), "Lamp color should match expectation.");
            testCase.verifyEqual(manager.SummaryLamp.Tooltip, char(expectedStatus), "Lamp tooltip should match expectation.");

            testCase.verifySize(manager.IndividualTable.Data, [19, 3], "Table size should match expectation.");
        end

        % Test that when no health data is available, nothing is shown.
        function ignoreOnNoHealthData(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            manager = mag.app.manage.HealthManager();
            manager.instantiate(panel);

            model = mag.app.bart.Model();
            manager.subscribe(model);

            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", "bart");

            testCase.assertEqual(manager.SummaryLayout.Visible, matlab.lang.OnOffSwitchState.off, "Summary should not be visible.");
            testCase.assertEqual(manager.IndividualPanel.Visible, matlab.lang.OnOffSwitchState.off, "Panel should not be visible.");
            testCase.assertEqual(manager.NoteLabel.Visible, matlab.lang.OnOffSwitchState.on, "Note should be visible.");

            % Exercise.
            model.analyze({"Location", location});

            % Verify.
            testCase.verifyEqual(manager.SummaryLayout.Visible, matlab.lang.OnOffSwitchState.off, "Summary should not be visible.");
            testCase.verifyEqual(manager.IndividualPanel.Visible, matlab.lang.OnOffSwitchState.off, "Panel should not be visible.");
            testCase.verifyEqual(manager.NoteLabel.Visible, matlab.lang.OnOffSwitchState.on, "Note should be visible.");
        end
    end
end
