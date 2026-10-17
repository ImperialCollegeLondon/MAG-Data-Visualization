classdef (TestTags = "System") tDataVisualization < AppTestCase
% TDATAVISUALIZATION System tests for "DataVisualization" app.

    properties (TestParameter)
        ValidMission = {"Bartington", "HENON", "HelioSwarm", "IMAP", "Vigil"}
        InvalidMission = {"SolarOrbiter", "Not a Mission"}
        BreakpointType = {mag.app.manage.ToolbarManager.DebugErrorID, mag.app.manage.ToolbarManager.DebugErrorSource}
    end

    methods (Test)

        % Test that app can be opened for all supported missions.
        function startApp_validMission(testCase, ValidMission)

            % Exercise.
            app = testCase.createAppWithCleanup(ValidMission);

            % Verify.
            testCase.verifySize(app, [1, 1], "App should have expected size.");
            testCase.verifyClass(app, "DataVisualization", "App should be of expected class.");

            testCase.verifyAppUIElementStatus(app, "off");
        end

        % Test that error is thrown for unsupported missions.
        function startApp_invalidMission(testCase, InvalidMission)
            testCase.verifyError(@() DataVisualization(InvalidMission), ?MException, "Error should be thrown on invalid mission.");
        end

        % Test that analyzing empty folder issues a warning.
        function analyze_noData(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());

            app = testCase.createAppWithCleanup("IMAP");

            % Exercise.
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.processData(app);

            % Verify.
            testCase.dismissDialog("uialert", app.UIFigure);
        end

        % Test that data is processed in the background, and UI is locked
        % while processing.
        function processData_background(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", true));
            app = testCase.createAppWithDataLocation("Bartington", "bart");

            % Exercise.
            testCase.press(app.ProcessDataButton);

            % Verify running state.
            testCase.verifyTrue(app.IsProcessing, "App should be processing.");
            testCase.verifyEqual(app.ProcessingTask.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Thread, ...
                "Processing should run on thread.");
            testCase.verifyEqual(string(app.ProcessDataButton.Text), "Cancel", "Button should allow cancelling.");
            testCase.verifyEqual(string(app.AnalyzeStatusLabel.Text), "Processing data...", "Status should show processing.");
            testCase.verifyLocked(app, true);

            % Verify completed state.
            testCase.waitForTasks(app);

            testCase.verifyFalse(app.IsProcessing, "App should not be processing.");
            testCase.verifyEqual(app.ProcessingTask.State, mag.app.internal.TaskState.Succeeded, "Processing should succeed.");
            testCase.verifyEqual(string(app.ProcessDataButton.Text), "Process Data", "Button should allow processing.");
            testCase.verifyTrue(startsWith(app.AnalyzeStatusLabel.Text, "Processing completed in"), "Status should show completion.");
            testCase.verifyLocked(app, false);

            testCase.verifyTrue(app.Model.HasAnalysis, "Analysis should be available.");
            testCase.verifyAppUIElementStatus(app, "on");
        end

        % Test that processing can be cancelled.
        function processData_cancel(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", true));
            app = testCase.createAppWithDataLocation("Bartington", "bart");

            testCase.press(app.ProcessDataButton);
            testCase.assertTrue(app.IsProcessing, "App should be processing.");

            % Exercise.
            testCase.press(app.ProcessDataButton);

            % Verify.
            testCase.verifyFalse(app.IsProcessing, "App should not be processing.");
            testCase.verifyEqual(app.ProcessingTask.State, mag.app.internal.TaskState.Cancelled, "Processing should be cancelled.");
            testCase.verifyEqual(string(app.ProcessDataButton.Text), "Process Data", "Button should allow processing.");
            testCase.verifyEqual(string(app.AnalyzeStatusLabel.Text), "Processing cancelled.", "Status should show cancellation.");
            testCase.verifyLocked(app, false);

            testCase.verifyFalse(app.Model.HasAnalysis, "Analysis should not be available.");
            testCase.verifyAppUIElementStatus(app, "off");
        end

        % Test that data can be processed again after cancelling.
        function processData_afterCancel(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", true));
            app = testCase.createAppWithDataLocation("Bartington", "bart");

            testCase.press(app.ProcessDataButton);
            testCase.press(app.ProcessDataButton);

            % Exercise.
            testCase.processData(app);

            % Verify.
            testCase.verifyEqual(app.ProcessingTask.State, mag.app.internal.TaskState.Succeeded, "Processing should succeed.");
            testCase.verifyTrue(app.Model.HasAnalysis, "Analysis should be available.");
            testCase.verifyAppUIElementStatus(app, "on");
        end

        % Test that data is processed in the foreground when background
        % processing is disabled.
        function processData_foreground(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", false));
            app = testCase.createAppWithDataLocation("Bartington", "bart");

            % Exercise.
            testCase.press(app.ProcessDataButton);

            % Verify.
            testCase.verifyFalse(app.IsProcessing, "Processing should complete before returning.");
            testCase.verifyEqual(app.ProcessingTask.CurrentEnvironment, mag.app.internal.ExecutionEnvironment.Foreground, ...
                "Processing should run in the foreground.");
            testCase.verifyEqual(app.ProcessingTask.State, mag.app.internal.TaskState.Succeeded, "Processing should succeed.");
            testCase.verifyLocked(app, false);

            testCase.verifyTrue(app.Model.HasAnalysis, "Analysis should be available.");
            testCase.verifyAppUIElementStatus(app, "on");
        end

        % Test that closing app while processing cancels processing.
        function processData_closeApp(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", true));
            app = testCase.createAppWithDataLocation("Bartington", "bart");

            testCase.press(app.ProcessDataButton);
            task = app.ProcessingTask;

            % Exercise.
            delete(app);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Cancelled, "Processing should be cancelled.");
        end

        % Test that existing analysis is imported in the background, and
        % UI is locked while importing.
        function importAnalysis(testCase)

            % Set up.
            testCase.applyFixture(mag.test.fixture.ToolboxSetting("BackgroundProcessing", true));
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());

            bartAnalysis = mag.bart.Analysis.start(Location = fullfile(mag.test.DataTestUtilities.SystemTestDataLocation, "bart"));

            matFile = fullfile(workingDirectory.Folder, "analysis.mat");
            save(matFile, "bartAnalysis");

            app = testCase.createAppWithCleanup("Bartington");

            % Exercise.
            app.importAnalysis(matFile);

            % Verify running state.
            testCase.verifyTrue(app.IsProcessing, "App should be importing.");
            testCase.verifyEqual(string(app.ProcessDataButton.Text), "Cancel", "Button should allow cancelling.");
            testCase.verifyEqual(string(app.AnalyzeStatusLabel.Text), "Importing...", "Status should show import.");
            testCase.verifyLocked(app, true);

            % Verify completed state.
            testCase.waitForTasks(app);
            testCase.dismissDialog("uialert", app.UIFigure);

            testCase.verifyEqual(app.ProcessingTask.State, mag.app.internal.TaskState.Succeeded, "Import should succeed.");
            testCase.verifyTrue(startsWith(app.AnalyzeStatusLabel.Text, "Import completed in"), "Status should show completion.");
            testCase.verifyLocked(app, false);

            testCase.verifyTrue(isequaln(app.Model.Analysis.Results, bartAnalysis.Results), "Analysis should be imported.");
            testCase.verifyAppUIElementStatus(app, "on");
        end

        % Test that importing MAT file without analysis shows an error.
        function importAnalysis_noAnalysis(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());

            matFile = fullfile(workingDirectory.Folder, "analysis.mat");
            otherVariable = pi;
            save(matFile, "otherVariable");

            app = testCase.createAppWithCleanup("Bartington");

            % Exercise.
            app.importAnalysis(matFile);
            testCase.waitForTasks(app);

            % Verify.
            testCase.dismissDialog("uialert", app.UIFigure);

            testCase.verifyEqual(app.ProcessingTask.State, mag.app.internal.TaskState.Failed, "Import should fail.");
            testCase.verifyEqual(string(app.AnalyzeStatusLabel.Text), "Import failed.", "Status should show failure.");
            testCase.verifyLocked(app, false);

            testCase.verifyFalse(app.Model.HasAnalysis, "Analysis should not be imported.");
        end

        % Test that debugging can be enabled.
        function toolbarDebug(testCase, BreakpointType)

            % Set up.
            testCase.restoreDebugStatePostTest();

            app = testCase.createAppWithCleanup("IMAP");

            testCase.processData(app);
            testCase.dismissDialog("uialert", app.UIFigure);

            % Exercise.
            testCase.chooseDialog("uiconfirm", app.UIFigure, @() testCase.press(app.ToolbarManager.DebugToggleTool), BreakpointType);

            % Verify.
            testCase.verifyNotEmpty(dbstatus(), "Breakpoint should be set.");

            % Clean up.
            testCase.press(app.ToolbarManager.DebugToggleTool);
            testCase.verifyEmpty(dbstatus(), "Breakpoint should be reset.");
        end

        % Test that alert is shown when enabling debugging with no error.
        function toolbarDebug_noError(testCase)

            % Set up.
            testCase.restoreDebugStatePostTest();

            app = testCase.createAppWithCleanup("IMAP");

            % Exercise.
            testCase.press(app.ToolbarManager.DebugToggleTool);

            % Verify.
            testCase.dismissDialog("uialert", app.UIFigure);
            testCase.verifyEmpty(dbstatus(), "No breakpoint should be set.");
        end

        % function selectMission(testCase, ValidMission)
        %
        %     % Set up.
        %     app = testCase.createAppWithCleanup(ValidMission);
        %
        %     % Exercise.
        %     testCase.press(app.ToolbarManager.MissionPushTool);
        %
        %     testCase.assertNotEmpty(app.SelectMissionDialog, "Mission selection dialog should not be empty.");
        %
        %     testCase.choose(app.SelectMissionDialog.MissionDropDown, ValidMission);
        %     testCase.press(app.SelectMissionDialog.SelectButton);
        %
        %     % Verify.
        %     testCase.verifyEqual(app.Mission, ValidMission, "Mission should be selected.");
        % end
    end

    methods (Access = private)

        function app = createAppWithDataLocation(testCase, mission, testFolder)

            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, testFolder);

            app = testCase.createAppWithCleanup(mission);
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
        end

        function verifyLocked(testCase, app, locked)

            expected = matlab.lang.OnOffSwitchState(~locked);

            testCase.verifyEqual(app.AnalyzeSettingsPanel.Enable, expected, "Settings should be locked only while processing.");
            testCase.verifyEqual(app.ResetButton.Enable, expected, "Reset should be locked only while processing.");
            testCase.verifyEqual(app.ToolbarManager.MissionPushTool.Enable, expected, "Toolbar should be locked only while processing.");
            testCase.verifyEqual(app.ToolbarManager.ImportPushTool.Enable, expected, "Toolbar should be locked only while processing.");
        end

        function restoreDebugStatePostTest(testCase)

            status = dbstatus();
            testCase.addTeardown(@() dbstop(status));

            dbclear("all");
            testCase.assertEmpty(dbstatus(), "Debugging status should be empty before test.");
        end
    end
end
