classdef tField < MAGControllerTestCase
% TFIELD Unit tests for "mag.app.control.Field" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();
            field = mag.app.control.Field(panel);

            % Exercise.
            field.instantiate();

            % Verify.
            testCase.verifyStartEndDateButtons(field, StartDateRow = 1, EndDateRow = 2);

            testCase.assertNotEmpty(field.EventsTree, "Events tree should not be empty.");
            testCase.assertNumElements(field.EventsTree.Children, 3, "Events tree should have 3 children.");

            testCase.verifyEqual(field.EventsTree.Layout, matlab.ui.layout.GridLayoutOptions(Row = [3, 4], Column = [2, 3]), ...
                "Events tree layout should match expectation.");

            testCase.verifyEqual(field.EventsTree.Children(1).Text, 'Compression', "First tree node should be ""Compression"".");
            testCase.verifyEqual(field.EventsTree.Children(2).Text, 'Mode', "Second tree node should be ""Mode"".");
            testCase.verifyEqual(field.EventsTree.Children(3).Text, 'Range', "Third tree node should be ""Range"".");
        end
    end
end
