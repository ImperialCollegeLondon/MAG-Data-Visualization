classdef tDataVisualization < AppTestCase
% TDATAVISUALIZATION System tests for "DataVisualization" app.

    properties (TestParameter)
        ValidMission = {"Bartington", "HelioSwarm", "IMAP"}
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
            testCase.press(app.ProcessDataButton);

            % Verify.
            testCase.dismissDialog("uialert", app.UIFigure);
        end

        % Test that debugging can be enabled.
        function toolbarDebug(testCase, BreakpointType)

            % Set up.
            testCase.restoreDebugStatePostTest();

            app = testCase.createAppWithCleanup("IMAP");

            testCase.press(app.ProcessDataButton);
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

        function restoreDebugStatePostTest(testCase)

            status = dbstatus();
            testCase.addTeardown(@() dbstop(status));

            dbclear("all");
            testCase.assertEmpty(dbstatus(), "Debugging status should be empty before test.");
        end
    end
end
