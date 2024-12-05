classdef tField < MAGControllerTestCase
% TFIELD Unit tests for "mag.app.imap.controlField" class.

    methods (Test)

        % Test that "instantiate" creates expected elements.
        function instantiate(testCase)

            % Set up.
            panel = testCase.createTestPanel();
            field = mag.app.imap.control.Field();

            % Exercise.
            field.instantiate(panel);

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

        % Test that "getVisualizeCommand" returns expected command.
        function getVisualizeCommand(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            field = mag.app.imap.control.Field();
            field.instantiate(panel);

            results = mag.imap.Instrument();

            % Exercise.
            command = field.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField("Events"), """Events"" should be a named argument.");
            testCase.verifyEmpty(command.NamedArguments.Events, """Events"" should be empty when none selected.");
        end

        % Test that "getVisualizeCommand" returns expected command, when
        % events have been selected.
        function getVisualizeCommand_selectedEvents(testCase)

            % Set up.
            panel = testCase.createTestPanel();

            field = mag.app.imap.control.Field();
            field.instantiate(panel);

            field.EventsTree.CheckedNodes = field.EventsTree.Children(2);

            results = mag.imap.Instrument();

            % Exercise.
            command = field.getVisualizeCommand(results);

            % Verify.
            testCase.verifyEqual(command.PositionalArguments, {results}, "Visualize command positional arguments should match expectation.");

            testCase.assertThat(command.NamedArguments, mag.test.constraint.IsField("Events"), """Events"" should be a named argument.");
            testCase.verifyEqual(command.NamedArguments.Events, "Mode", """Events"" should match expectation.");
        end
    end
end
