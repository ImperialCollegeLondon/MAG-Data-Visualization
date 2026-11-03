classdef (TestTags = "System") tVigilApp < AppTestCase
% TVIGILAPP System tests for Vigil version of "DataVisualization" app.

    methods (Test)

        % Test that analysis with only outboard data works.
        function analyze_outboardOnly(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, "vigil");

            delete(fullfile(workingDirectory.Folder, "fib_sci_*.log.txt"));

            app = testCase.createAppWithCleanup("Vigil");

            % Exercise.
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.processData(app);

            % Verify.
            testCase.verifyAppUIElementStatus(app, "on");
            testCase.verifyTrue(app.Model.Analysis.Results.Outboard.HasData, "Outboard should have data.");
            testCase.verifyFalse(app.Model.Analysis.Results.Inboard.HasData, "Inboard should not have data.");
        end

        % Test that analysis with only inboard data works.
        function analyze_inboardOnly(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, "vigil");

            delete(fullfile(workingDirectory.Folder, "fob_sci_*.log.txt"));

            app = testCase.createAppWithCleanup("Vigil");

            % Exercise.
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.processData(app);

            % Verify.
            testCase.verifyAppUIElementStatus(app, "on");
            testCase.verifyFalse(app.Model.Analysis.Results.Outboard.HasData, "Outboard should not have data.");
            testCase.verifyTrue(app.Model.Analysis.Results.Inboard.HasData, "Inboard should have data.");
        end
    end
end
