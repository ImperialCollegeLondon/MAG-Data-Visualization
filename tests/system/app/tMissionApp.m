classdef (TestTags = "System") tMissionApp < AppTestCase
% TMISSIONAPP System tests for versions of "DataVisualization" app that
% share the same workflow.

    properties (TestParameter)
        Mission = struct( ...
            Bartington = struct(Name = "Bartington", Folder = "bart", ...
            Views = ["Field", "PSD", "Signal Analyzer", "Spectrogram", "Wavelet Analyzer"], Sensors = string.empty()), ...
            HENON = struct(Name = "HENON", Folder = "henon", ...
            Views = ["Field", "PSD", "Signal Analyzer", "Spectrogram", "Wavelet Analyzer"], Sensors = ["Outboard", "Inboard"]), ...
            Vigil = struct(Name = "Vigil", Folder = "vigil", ...
            Views = ["Field", "PSD", "Signal Analyzer", "Spectrogram", "Wavelet Analyzer"], Sensors = ["Outboard", "Inboard"]))
        InvalidLocation = {'', "this/folder/does-not/exist"}
    end

    methods (Test)

        % Test that full analysis workflow is supported.
        function analyze_fullWorkflow(testCase, Mission)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, Mission.Folder);

            app = testCase.createAppWithCleanup(Mission.Name);

            % Exercise and verify processing.
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.processData(app);

            testCase.verifyAppUIElementStatus(app, "on");
            testCase.verifyTrue(app.ResultsManager.SciencePreviewPanel.Enable, "Science preview should be enabled.");
            testCase.verifyNotEmpty(app.ResultsManager.StackedChartPreview, "Science preview should be populated.");

            for s = Mission.Sensors
                testCase.verifyTrue(app.Model.Analysis.Results.(s).HasData, compose("%s should have data.", s));
            end

            testCase.verifyEqual(app.VisualizationManager.VisualizationTypeListBox.Items, cellstr(Mission.Views));

            % Exercise and verify reset.
            testCase.resetApp(app);
        end

        % Test that invalid location throws an error.
        function invalidLocation(testCase, Mission, InvalidLocation)

            % Set up.
            app = testCase.createAppWithCleanup(Mission.Name);

            % Exercise.
            testCase.type(app.AnalysisManager.LocationEditField, InvalidLocation);
            testCase.processData(app);

            % Verify.
            testCase.dismissDialog("uialert", app.UIFigure);
        end
    end

    methods (Access = private)

        function resetApp(testCase, app)

            testCase.choose(app.AnalyzeTab);
            testCase.press(app.ResetButton);

            testCase.verifyAppUIElementStatus(app, "off");

            testCase.verifyEmpty(app.Model.Analysis, "Analysis should be reset.");
            testCase.verifyEmpty(app.AnalysisManager.LocationEditField.Value, "Location should be reset.");

            testCase.verifyFalse(app.ResultsManager.SciencePreviewPanel.Enable, "Science preview should be disabled.");
        end
    end
end
