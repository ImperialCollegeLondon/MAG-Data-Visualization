classdef tModel < mag.test.case.ViewControllerTestCase
% TMODEL Unit tests for "mag.app.Model" classes.

    properties (Access = private)
        EventTriggered (1, 1) logical = false
    end

    properties (Constant, Access = private)
        Timeout (1, 1) double = 120
    end

    properties (TestParameter)
        ModelDetails = { ...
            struct(Model = "mag.app.bart.Model", Analysis = "mag.bart.Analysis"), ...
            struct(Model = "mag.app.henon.Model", Analysis = "mag.henon.Analysis"), ...
            struct(Model = "mag.app.hs.Model", Analysis = "mag.hs.Analysis"), ...
            struct(Model = "mag.app.imap.Model", Analysis = "mag.imap.Analysis"), ...
            struct(Model = "mag.app.vigil.Model", Analysis = "mag.vigil.Analysis")}
        AnalysisDetails = { ...
            struct(Model = "mag.app.bart.Model", Analysis = "mag.bart.Analysis", Folder = "bart"), ...
            struct(Model = "mag.app.henon.Model", Analysis = "mag.henon.Analysis", Folder = "henon"), ...
            struct(Model = "mag.app.hs.Model", Analysis = "mag.hs.Analysis", Folder = fullfile("hs", "single_file")), ...
            struct(Model = "mag.app.vigil.Model", Analysis = "mag.vigil.Analysis", Folder = "vigil")}
    end

    methods (Test)

        % Test that analysis is correctly loaded from MAT file.
        function load(testCase, ModelDetails)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());

            analysis = feval(ModelDetails.Analysis, Location = pwd());
            otherVariable = pi;

            save(workingDirectory.Folder, "analysis", "otherVariable");

            % Exercise.
            testCase.EventTriggered = false;

            model = feval(ModelDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            model.load(workingDirectory.Folder);

            % Verify.
            testCase.verifyEqual(analysis, model.Analysis, "Analysis should be loaded correctly.");
            testCase.verifyTrue(testCase.EventTriggered, "Event should trigger on analysis change.");
        end

        % Test that error is thrown if no valid analysis exists in MAT
        % file.
        function load_noAnalysis(testCase, ModelDetails)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());

            otherVariable = pi;
            save(workingDirectory.Folder, "otherVariable");

            % Exercise and verify.
            testCase.EventTriggered = false;

            model = feval(ModelDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            testCase.verifyError(@() model.load(workingDirectory.Folder), ?MException, ...
                "Error should be thrown when no valid analysis exists.");

            testCase.verifyFalse(model.HasAnalysis, "Analysis should not be loaded.");
            testCase.verifyFalse(testCase.EventTriggered, "Event should not trigger when no analysis change.");
        end

        % Test that load task loads analysis in the background and
        % updates model on success.
        function createLoadTask(testCase, ModelDetails)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            matFile = fullfile(workingDirectory.Folder, "analysis.mat");

            analysis = feval(ModelDetails.Analysis, Location = pwd());
            otherVariable = pi;

            save(matFile, "otherVariable", "analysis");

            testCase.EventTriggered = false;

            model = feval(ModelDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            % Exercise.
            task = model.createLoadTask(matFile);

            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Pending, "Task should not be started.");

            task.start();
            testCase.assertTrue(task.wait(testCase.Timeout), "Task should complete.");

            % Verify.
            testCase.assertEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");

            testCase.verifyEqual(model.Analysis, analysis, "Analysis should be loaded correctly.");
            testCase.verifyTrue(testCase.EventTriggered, "Event should trigger on analysis change.");
        end

        % Test that load task fails if no valid analysis exists in MAT
        % file.
        function createLoadTask_noAnalysis(testCase, ModelDetails)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
            matFile = fullfile(workingDirectory.Folder, "analysis.mat");

            otherVariable = pi;
            save(matFile, "otherVariable");

            testCase.EventTriggered = false;

            model = feval(ModelDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            % Exercise.
            task = model.createLoadTask(matFile);
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.verifyEqual(task.Error.identifier, 'mag:app:InvalidMAT', "Error identifier should match expectation.");

            testCase.verifyFalse(model.HasAnalysis, "Analysis should not be loaded.");
            testCase.verifyFalse(testCase.EventTriggered, "Event should not trigger when no analysis change.");
        end

        % Test that load task cannot be created for nonexistent file.
        function createLoadTask_nonexistentFile(testCase)

            % Set up.
            model = mag.app.bart.Model();

            % Exercise and verify.
            testCase.verifyError(@() model.createLoadTask("this/file/does-not/exist.mat"), "MATLAB:validators:mustBeFile", ...
                "Error should be thrown when file does not exist.");
        end

        % Test that analysis task runs analysis in the background and
        % updates model on success.
        function createAnalysisTask(testCase, AnalysisDetails)

            % Set up.
            location = testCase.getTestDataLocation(AnalysisDetails.Folder);

            testCase.EventTriggered = false;

            model = feval(AnalysisDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            % Exercise.
            task = model.createAnalysisTask({"Location", location});

            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Pending, "Task should not be started.");
            testCase.verifyEqual(task.Name, AnalysisDetails.Analysis + ".start", "Task name should match expectation.");

            task.start();
            testCase.assertTrue(task.wait(testCase.Timeout), "Task should complete.");

            % Verify.
            testCase.assertEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");

            testCase.verifyTrue(testCase.EventTriggered, "Event should trigger on analysis change.");
            testCase.verifyTrue(model.HasAnalysis, "Analysis should be available.");
            testCase.verifyClass(model.Analysis, AnalysisDetails.Analysis, "Analysis should be of expected class.");
            testCase.verifyEqual(model.Analysis.Location, string(location), "Analysis location should match expectation.");
        end

        % Test that analysis task gives same results as synchronous
        % analysis.
        function createAnalysisTask_sameAsAnalyze(testCase, AnalysisDetails)

            % Set up.
            location = testCase.getTestDataLocation(AnalysisDetails.Folder);

            expectedModel = feval(AnalysisDetails.Model);
            expectedModel.analyze({"Location", location});

            % Exercise.
            model = feval(AnalysisDetails.Model);

            task = model.createAnalysisTask({"Location", location});
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.assertEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");
            testCase.verifyTrue(isequaln(model.Analysis.Results, expectedModel.Analysis.Results), ...
                "Background analysis results should match foreground analysis results.");
        end

        % Test that failed analysis task does not change model.
        function createAnalysisTask_error(testCase, AnalysisDetails)

            % Set up.
            testCase.EventTriggered = false;

            model = feval(AnalysisDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            % Exercise.
            task = model.createAnalysisTask({"Location", "this/folder/does-not/exist"});
            task.start();
            task.wait(testCase.Timeout);

            % Verify.
            testCase.verifyEqual(task.State, mag.app.internal.TaskState.Failed, "Task should fail.");
            testCase.verifyNotEmpty(task.Error, "Task error should be set.");

            testCase.verifyFalse(model.HasAnalysis, "Analysis should not be set.");
            testCase.verifyFalse(testCase.EventTriggered, "Event should not trigger when no analysis change.");
        end

        % Test that export task exports analysis in the background.
        function createExportTask(testCase)

            % Set up.
            workingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());

            model = mag.app.hs.Model();
            model.analyze({"Location", testCase.getTestDataLocation(fullfile("hs", "single_file"))});

            % Exercise.
            task = model.createExportTask({"MAT", "Location", workingDirectory.Folder});

            testCase.verifyEqual(task.Name, "mag.hs.Analysis.export", "Task name should match expectation.");

            task.start();
            testCase.assertTrue(task.wait(testCase.Timeout), "Task should complete.");

            % Verify.
            testCase.assertEqual(task.State, mag.app.internal.TaskState.Succeeded, "Task should succeed.");
            testCase.verifyNotEmpty(dir(fullfile(workingDirectory.Folder, "*.mat")), "Exported files should exist.");
        end

        % Test that export task cannot be created without analysis.
        function createExportTask_noAnalysis(testCase, ModelDetails)

            % Set up.
            model = feval(ModelDetails.Model);

            % Exercise and verify.
            testCase.verifyError(@() model.createExportTask({"MAT"}), "mag:app:NoAnalysis", ...
                "Error should be thrown when no analysis exists.");
        end

        % Test that analysis can be reset.
        function reset(testCase, ModelDetails)

            % Set up.
            testCase.EventTriggered = false;

            model = feval(ModelDetails.Model);
            model.addlistener("ModelChanged", @testCase.trigger);

            % Exercise.
            model.reset();

            % Verify.
            testCase.assertFalse(model.HasAnalysis, "Analysis should be reset.");

            testCase.verifyEmpty(model.Analysis, "Analysis should be reset correctly.");
            testCase.verifyTrue(testCase.EventTriggered, "Event should trigger on analysis change.");
        end
    end

    methods (Access = private)

        function trigger(testCase, ~, ~)
            testCase.EventTriggered = true;
        end
    end

    methods (Static, Access = private)

        function location = getTestDataLocation(folder)
            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", folder);
        end
    end
end
