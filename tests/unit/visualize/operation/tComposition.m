classdef (TestTags = ["Unit", "Parallel"]) tComposition < matlab.mock.TestCase
% TCOMPOSITION Unit tests for "mag.graphics.operation.Composition" class.

    methods (Test)

        % Test that "apply" method converts values correctly.
        function apply(testCase)

            % Set up.
            [mockAction1, actionBehavior1] = testCase.createMock(?mag.graphics.operation.Action);
            [mockAction2, actionBehavior2] = testCase.createMock(?mag.graphics.operation.Action);

            composition = mag.graphics.operation.Composition(Operations = [mockAction1, mockAction2]);

            testCase.assignOutputsWhen(withAnyInputs(actionBehavior1.apply), (1:10)');
            testCase.assignOutputsWhen(withAnyInputs(actionBehavior2.apply), (11:20)');

            expectedValue = (11:20)';

            % Exercise.
            actualValue = composition.apply(table.empty());

            % Verify.
            testCase.verifyEqual(actualValue, expectedValue, "Converted result should be as expected.");

            testCase.verifyCalled(withAnyInputs(actionBehavior1.apply), "Expected behavior to be called once.");
            testCase.verifyCalled(withAnyInputs(actionBehavior2.apply), "Expected behavior to be called once.");
        end
    end
end
