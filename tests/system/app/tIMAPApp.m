classdef tIMAPApp < AppTestCase
% TIMAPAPP System tests for IMAP version of "DataVisualization" app.

    properties (TestParameter)
        TestDetails = {
            struct(Folder = "imap/full_analysis", Instrument = '', Primary = '', Secondary = '', ...
            Views = ["AT/SFT", "CPT", "Field", "HK", "I-ALiRT", "PSD", "Spectrogram", "Timestamp"]), ...
            struct(Folder = "imap/fob_only", Instrument = '', Primary = '', Secondary = '', ...
            Views = ["AT/SFT", "CPT", "Field", "HK", "I-ALiRT", "PSD", "Spectrogram", "Timestamp"]), ...
            struct(Folder = "imap/sc_test", Instrument = "FM - BSW: 2.04 - ASW: 4.05", Primary = "FOB (FEE3 - FM5 - None)", Secondary = "FIB (FEE4 - FM4 - None)", ...
            Views = ["AT/SFT", "CPT", "Field", "HK", "PSD", "Spectrogram", "Timestamp"])}
        InvalidLocation = {'', "this/folder/does-not/exist"}
    end

    methods (Test)

        % Test that full analysis workflow is supported.
        function analyze_fullWorkflow(testCase, TestDetails)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, TestDetails.Folder);

            app = testCase.createAppWithCleanup("IMAP");

            % Exercise and verify processing.
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.press(app.ProcessDataButton);

            testCase.verifyAppUIElementStatus(app, "on");
            testCase.verifyTrue(app.ResultsManager.MetadataPanel.Enable, "Metadata panel should be enabled.");
            testCase.verifyTrue(app.ResultsManager.SciencePreviewPanel.Enable, "Science preview should be enabled.");
            testCase.verifyNotEmpty(app.ResultsManager.StackedChartPreview, "Science preview should be populated.");

            testCase.verifyEqual(app.ResultsManager.InstrumentTextArea.Value, cellstr(TestDetails.Instrument));
            testCase.verifyEqual(app.ResultsManager.PrimaryTextArea.Value, cellstr(TestDetails.Primary));
            testCase.verifyEqual(app.ResultsManager.SecondaryTextArea.Value, cellstr(TestDetails.Secondary));

            testCase.verifyEqual(app.VisualizationManager.VisualizationTypeListBox.Items, cellstr(TestDetails.Views));

            % Exercise and verify reset.
            testCase.resetApp(app);
        end

        % Test that invalid location throws an error.
        function invalidLocation(testCase, InvalidLocation)

            % Set up.
            app = testCase.createAppWithCleanup("IMAP");

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

            testCase.verifyFalse(app.ResultsManager.MetadataPanel.Enable, "Metadata panel should be disabled.");
            testCase.verifyFalse(app.ResultsManager.SciencePreviewPanel.Enable, "Science preview should be disabled.");
        end
    end
end
