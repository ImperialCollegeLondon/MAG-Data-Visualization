classdef tVisualize < AppTestCase
% TVISUALIZE System tests for visualizing "DataVisualization" results.

    properties (Constant, Access = private)
        ExcludedViews (1, :) string = mag.app.control.WaveletAnalyzer.Name
    end

    properties (Access = private)
        App DataVisualization {mustBeScalarOrEmpty}
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    properties (ClassSetupParameter)
        TestDetails = {
            struct(Folder = "bart", Mission = mag.meta.Mission.Bartington, NumShownFigures = 3, NumSavedFigures = 3), ...
            struct(Folder = "hs", Mission = mag.meta.Mission.HelioSwarm, NumShownFigures = 3, NumSavedFigures = 3), ...
            struct(Folder = "imap/full_analysis", Mission = mag.meta.Mission.IMAP, NumShownFigures = 37, NumSavedFigures = 28)}
    end

    methods (TestClassSetup)

        function initializeApp(testCase, TestDetails)

            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(testCase.WorkingDirectory, TestDetails.Folder);

            testCase.App = testCase.createAppWithCleanup(TestDetails.Mission);

            testCase.choose(testCase.App.AnalyzeTab);
            testCase.type(testCase.App.AnalysisManager.LocationEditField, testCase.WorkingDirectory.Folder);
            testCase.press(testCase.App.ProcessDataButton);

            testCase.choose(testCase.App.VisualizeTab);
            testCase.press(testCase.App.ShowFiguresButton);
            testCase.dismissDialog("uialert", testCase.App.UIFigure);
        end
    end

    methods (TestClassTeardown)

        % Close any apps that are not considered figures.
        function closeAnalyzers(~)

            try
                signal.analyzer.Instance.close();
            catch exception
                warning(exception.identifier, "Could not close Signal Analyzer: %s", exception.message);
            end
        end
    end

    methods (Test)

        % Test that showing figures is supported.
        function showFigures(testCase, TestDetails)

            % Set up.
            testCase.verifyFalse(testCase.App.SaveFiguresButton.Enable, """Save Figures"" button should be disabled.");
            testCase.verifyFalse(testCase.App.CloseFiguresButton.Enable, """Close Figures"" button should be disabled.");

            % Exercise.
            for view = string(testCase.App.VisualizationManager.VisualizationTypeListBox.Items)

                if ismember(view, testCase.ExcludedViews)

                    testCase.log(compose("Excluding view %s.", view));
                    continue;
                end

                testCase.choose(testCase.App.VisualizationManager.VisualizationTypeListBox, view);
                testCase.press(testCase.App.ShowFiguresButton);
            end

            % Verify.
            testCase.verifyTrue(testCase.App.SaveFiguresButton.Enable, """Save Figures"" button should be enabled.");
            testCase.verifyTrue(testCase.App.CloseFiguresButton.Enable, """Close Figures"" button should be enabled.");

            testCase.verifyNumElements(testCase.App.Figures, TestDetails.NumShownFigures, "Figures should be generated.");
        end

        % Test that saving figures is supported.
        function saveFigures(testCase, TestDetails)

            % Set up.
            saveFolder = fullfile(testCase.WorkingDirectory.Folder, compose("Results (v%s)", mag.version()));

            % Exercise.
            testCase.assertFalse(isfolder(saveFolder), "Save folder should not exist yet.");
            testCase.press(testCase.App.SaveFiguresButton);

            % Verify.
            testCase.assertTrue(isfolder(saveFolder), "Save folder should exist.");

            savedFIGs = dir(fullfile(saveFolder, "*.fig"));
            savedPNGs = dir(fullfile(saveFolder, "*.png"));

            testCase.verifyNumElements(savedFIGs, TestDetails.NumSavedFigures, "Figures should be saved as "".fig"" files.");
            testCase.verifyNumElements(savedPNGs, TestDetails.NumSavedFigures, "Figures should be saved as "".png"" files.");
        end

        % Test that closing figures is supported.
        function closeFigures(testCase)

            % Set up.
            testCase.verifyTrue(testCase.App.SaveFiguresButton.Enable, """Save Figures"" button should be enabled.");
            testCase.verifyTrue(testCase.App.CloseFiguresButton.Enable, """Close Figures"" button should be enabled.");

            % Exercise.
            testCase.press(testCase.App.CloseFiguresButton);

            % Verify.
            testCase.verifyFalse(testCase.App.SaveFiguresButton.Enable, """Save Figures"" button should be disabled.");
            testCase.verifyFalse(testCase.App.CloseFiguresButton.Enable, """Close Figures"" button should be disabled.");

            testCase.verifyEmpty(testCase.App.Figures, "Figures should be closed.");
        end
    end
end
