classdef tHelioSwarmApp < AppTestCase
% THELIOSWARMAPP System tests for HelioSwarm version of "DataVisualization"
% app.

    properties (TestParameter)
        TestDetails = {
            struct(Folder = "hs/single_file", ...
            Views = ["Field", "HK", "PSD", "Signal Analyzer", "Spectrogram", "Wavelet Analyzer"])}
        InvalidLocation = {'', "this/folder/does-not/exist"}
    end

    methods (Test)

        % Test that HelioSwarm complete scale factors table is populated correctly.
        function scaleFactorsTable_populated(testCase)

            % Set up.
            app = testCase.createAppWithCleanup("HelioSwarm");

            % Verify.
            tableData = string(app.AnalysisManager.ScaleFactorsTable.Data);
            expectedData = mag.hs.Analysis.getCompleteScaleFactors();
            actualData = str2double(tableData);

            testCase.verifySize(tableData, [3, 4], ...
                "Scale factors table should be a 3x4 matrix.");
            testCase.verifyEqual(actualData, expectedData, ...
                "Scale factors table should display the correct scale factor values.", RelTol = 1e-6);
        end

        % Test that HelioSwarm scale factors table is editable.
        function scaleFactorsTable_editable(testCase)

            % Set up.
            app = testCase.createAppWithCleanup("HelioSwarm");

            % Verify.
            testCase.verifyTrue(all(app.AnalysisManager.ScaleFactorsTable.ColumnEditable), ...
                "Scale factors table columns should all be editable.");
        end

        % Test that edited HelioSwarm scale factors are used by analysis.
        function analyze_editedScaleFactorsUsed(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, "hs/single_file");

            app = testCase.createAppWithCleanup("HelioSwarm");
            testCase.type(app.AnalysisManager.LocationEditField, workingDirectory.Folder);

            editedScaleFactors = mag.hs.Analysis.getCompleteScaleFactors();
            editedScaleFactors(1, 1) = editedScaleFactors(1, 1) * 1.1;
            app.AnalysisManager.ScaleFactorsTable.Data = compose("%.15g", editedScaleFactors);
            expectedScaleFactors = str2double(string(app.AnalysisManager.ScaleFactorsTable.Data));

            % Exercise.
            testCase.press(app.ProcessDataButton);

            % Verify.
            testCase.verifyEqual(app.Model.Analysis.ScaleFactors, expectedScaleFactors, ...
                "Analysis should use edited HelioSwarm scale factors.", RelTol = 1e-12);
        end

        % Test that edited HelioSwarm scale factors scale science data
        % according to each axis and range factor.
        function analyze_editedScaleFactorsScaleScienceData(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            testCase.copyDataToWorkingDirectory(workingDirectory, "hs/single_file");

            % Analyze with default scale factors.
            appDefault = testCase.createAppWithCleanup("HelioSwarm");
            testCase.type(appDefault.AnalysisManager.LocationEditField, workingDirectory.Folder);
            testCase.press(appDefault.ProcessDataButton);

            defaultScience = appDefault.Model.Analysis.Results.Science;

            % Analyze with edited scale factors.
            appEdited = testCase.createAppWithCleanup("HelioSwarm");
            testCase.type(appEdited.AnalysisManager.LocationEditField, workingDirectory.Folder);

            baseScaleFactors = mag.hs.Analysis.getCompleteScaleFactors();
            multiplierMatrix = [1.1, 0.9, 1.3, 0.8; ...
                0.95, 1.2, 0.85, 1.4; ...
                1.05, 0.92, 1.25, 0.88];

            modifiedScaleFactors = baseScaleFactors .* multiplierMatrix;
            appEdited.AnalysisManager.ScaleFactorsTable.Data = compose("%.15g", modifiedScaleFactors);
            expectedScaleFactors = str2double(string(appEdited.AnalysisManager.ScaleFactorsTable.Data));

            testCase.press(appEdited.ProcessDataButton);

            editedScience = appEdited.Model.Analysis.Results.Science;


            
            % Verify.
            testCase.verifyEqual(numel(editedScience), numel(defaultScience), ...
                "Number of science channels should be unchanged.");
            testCase.verifyEqual(appEdited.Model.Analysis.ScaleFactors, expectedScaleFactors, ...
                "Analysis should use edited scale factors.", RelTol = 1e-12);

            for idx = 1:numel(defaultScience)

                defaultXYZ = defaultScience(idx).XYZ;
                editedXYZ = editedScience(idx).XYZ;
                ranges = double(defaultScience(idx).Range);

                expectedXYZ = defaultXYZ;
                for rangeIdx = 0:3

                    locRange = ranges == rangeIdx;
                    for axisIdx = 1:3
                        expectedXYZ(locRange, axisIdx) = expectedScaleFactors(axisIdx, rangeIdx + 1) .* ...
                            defaultXYZ(locRange, axisIdx) ./ baseScaleFactors(axisIdx, rangeIdx + 1);
                    end
                end

                testCase.verifyEqual(size(editedXYZ), size(defaultXYZ), ...
                    "Science data size should be unchanged.");
                testCase.verifyEqual(editedXYZ, expectedXYZ, ...
                    "Science data should scale with edited per-axis/per-range factors.", RelTol = 1e-6, AbsTol = 1e-8);
            end
        end

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
