classdef tField < mag.test.case.ViewControllerTestCase & matlab.mock.TestCase
% TFIELD Unit tests for "mag.app.control.Field" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            field = mag.app.control.Field(@mag.bart.view.Field);
            field.Model = model;

            % Exercise.
            field.instantiate(panel);

            % Verify.
            testCase.verifyStartEndDateButtons(field);
        end

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            model = mag.app.bart.Model();
            model.analyze({});

            field = mag.app.control.Field(@mag.bart.view.Field);
            field.Model = model;
            field.instantiate(panel);

            results = mag.bart.Instrument();

            % Exercise.
            command = field.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");
            testCase.verifyEmpty(command.NamedArguments, "Named arguments should be empty.");
        end
    end
end
