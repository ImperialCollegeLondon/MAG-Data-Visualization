classdef tHelioSwarmApp < AppTestCase
% THELIOSWARMAPP System tests for HelioSwarm version of "DataVisualization"
% app.

    properties (TestParameter)
        TestDetails = {
            struct(Folder = "hs", ...
            Views = ["Field", "HK", "PSD", "Signal Analyzer", "Spectrogram", "Wavelet Analyzer"])}
        InvalidLocation = {'', "this/folder/does-not/exist"}
    end

    methods (Test)

        % Test that full analysis workflow is supported.
        function analyze_fullWorkflow(testCase, TestDetails)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, TestDetails.Folder);

            app = testCase.createAppWithCleanup("HelioSwarm");

            % Exercise and verify processing.
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.press(app.ProcessDataButton);

            testCase.verifyAppUIElementStatus(app, "on");
            testCase.verifyTrue(app.ResultsManager.SciencePreviewPanel.Enable, "Science preview should be enabled.");
            testCase.verifyNotEmpty(app.ResultsManager.StackedChartPreview, "Science preview should be populated.");

            testCase.verifyEqual(app.VisualizationManager.VisualizationTypeListBox.Items, cellstr(TestDetails.Views));

            % Exercise and verify reset.
            testCase.resetApp(app);
        end

        % Test that invalid location throws an error.
        function invalidLocation(testCase, InvalidLocation)

            % Set up.
            app = testCase.createAppWithCleanup("HelioSwarm");

            % Exercise.
            testCase.type(app.AnalysisManager.LocationEditField, InvalidLocation);
            testCase.press(app.ProcessDataButton);

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
