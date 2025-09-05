classdef tModel < mag.test.case.ViewControllerTestCase
% TMODEL Unit tests for "mag.app.Model" classes.

    properties (Access = private)
        EventTriggered (1, 1) logical = false
    end

    properties (TestParameter)
        ModelDetails = { ...
            struct(Model = "mag.app.bart.Model", Analysis = "mag.bart.Analysis"), ...
            struct(Model = "mag.app.hs.Model", Analysis = "mag.hs.Analysis"), ...
            struct(Model = "mag.app.imap.Model", Analysis = "mag.imap.Analysis")}
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
end
