classdef tDataVisualization < AppTestCase
% TDATAVISUALIZATION System tests for "DataVisualization" app.

    properties (TestParameter)
        ValidMission = {"Bartington", "HelioSwarm", "IMAP"}
        InvalidMission = {"SolarOrbiter", "Not a Mission"}
    end

    methods (Test)

        function startApp_validMission(testCase, ValidMission)

            % Exercise.
            app = testCase.createAppWithCleanup(ValidMission);

            % Verify.
            testCase.verifySize(app, [1, 1], "App should have expected size.");
            testCase.verifyClass(app, "DataVisualization", "App should be of expected class.");

            testCase.verifyAppUIElementStatus(app, "off");
        end

        function startApp_invalidMission(testCase, InvalidMission)
            testCase.verifyError(@() DataVisualization(InvalidMission), ?MException, "Error should be thrown on invalid mission.");
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
end
