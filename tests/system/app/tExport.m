classdef tExport < AppTestCase
% TEXPORT System tests for exporting "DataVisualization" results.
%#ok<*EVALIN>

    properties (Access = private)
        App DataVisualization {mustBeScalarOrEmpty}
        Mission (1, 1) mag.meta.Mission
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    properties (ClassSetupParameter)
        TestDetails = {
            struct(Folder = "bart", Mission = mag.meta.Mission.Bartington), ...
            struct(Folder = "hs", Mission = mag.meta.Mission.HelioSwarm), ...
            struct(Folder = "imap/full_analysis", Mission = mag.meta.Mission.IMAP)}
    end

    methods (TestClassSetup)

        function initializeApp(testCase, TestDetails)

            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(testCase.WorkingDirectory, TestDetails.Folder);

            testCase.Mission = TestDetails.Mission;
            testCase.App = testCase.createAppWithCleanup(TestDetails.Mission);

            testCase.choose(testCase.App.AnalyzeTab);
            testCase.type(testCase.App.AnalysisManager.LocationEditField, testCase.WorkingDirectory.Folder);
            testCase.press(testCase.App.ProcessDataButton);
        end
    end

    methods (Test)

        function exportToWorkspace(testCase)

            % Set up.
            variableName = compose("%sAnalysis", lower(testCase.Mission.ShortName));

            testCase.choose(testCase.App.ExportTab);
            testCase.choose(testCase.App.ExportFormatDropDown, DataVisualization.ExportWorkspace);

            % Exercise.
            testCase.addTeardown(@() evalin("base", compose("clearvars('%s')", variableName)));
            testCase.press(testCase.App.ExportButton);

            % Verify.
            testCase.verifyTrue(evalin("base", compose("exist('%s')", variableName)) > 0, "Exported variable should exist in Workspace.");
        end

        function exportToWorkspace_overwrite(testCase)

            % Set up.
            variableName = compose("%sAnalysis", lower(testCase.Mission.ShortName));

            testCase.choose(testCase.App.ExportTab);
            testCase.choose(testCase.App.ExportFormatDropDown, DataVisualization.ExportWorkspace);

            % Exercise.
            testCase.addTeardown(@() evalin("base", compose("clearvars('%s')", variableName)));
            testCase.press(testCase.App.ExportButton);

            testCase.chooseDialog("uiconfirm", testCase.App.UIFigure, @() testCase.press(testCase.App.ExportButton), "OK");

            % Verify.
            testCase.verifyTrue(evalin("base", compose("exist('%s')", variableName)) > 0, "Exported variable should exist in Workspace.");
        end

        function exportToMATFile(testCase)

            % Set up.
            variableName = compose("%sAnalysis", lower(testCase.Mission.ShortName));
            exportFolder = fullfile(testCase.WorkingDirectory.Folder, compose("Results (v%s)", mag.version()));
            exportFile = fullfile(exportFolder, "Data.mat");

            testCase.choose(testCase.App.ExportTab);
            testCase.choose(testCase.App.ExportFormatDropDown, DataVisualization.ExportMAT);

            % Exercise.
            testCase.addTeardown(@() rmdir(exportFolder, "s"));
            testCase.press(testCase.App.ExportButton);

            % Verify.
            testCase.assertTrue(isfolder(exportFolder), "Export folder should exist.");
            testCase.assertTrue(isfile(exportFile), "Export file should exist.");

            exportedResults = load(exportFile);
            testCase.assertThat(exportedResults, mag.test.constraint.IsField(variableName), "Analysis should be exported.");

            if mag.test.isGitHub()
                testCase.log("Skip comparison with baseline on GitHub CI runner.");
            else
                testCase.verifyEqualsBaseline(exportedResults.(variableName).Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
            end
        end

        function exportToMATFile_append(testCase)

            % Set up.
            variableName = compose("%sAnalysis", lower(testCase.Mission.ShortName));
            exportFolder = fullfile(testCase.WorkingDirectory.Folder, compose("Results (v%s)", mag.version()));
            exportFile = fullfile(exportFolder, "Data.mat");

            anotherAnalysis = mag.hs.Analysis();

            mkdir(exportFolder);
            save(exportFile, "anotherAnalysis");

            testCase.choose(testCase.App.ExportTab);
            testCase.choose(testCase.App.ExportFormatDropDown, DataVisualization.ExportMAT);

            % Exercise.
            testCase.addTeardown(@() rmdir(exportFolder, "s"));
            testCase.press(testCase.App.ExportButton);

            % Verify.
            testCase.assertTrue(isfolder(exportFolder), "Export folder should exist.");
            testCase.assertTrue(isfile(exportFile), "Export file should exist.");

            exportedResults = load(exportFile);

            testCase.verifyThat(exportedResults, mag.test.constraint.IsField("anotherAnalysis"), "Other analysis should still exist.");
            testCase.assertThat(exportedResults, mag.test.constraint.IsField(variableName), "Analysis should be exported.");

            if mag.test.isGitHub()
                testCase.log("Skip comparison with baseline on GitHub CI runner.");
            else
                testCase.verifyEqualsBaseline(exportedResults.(variableName).Results, matlabtest.baselines.MATFileBaseline("results.mat", VariableName = "results"));
            end
        end
    end
end
