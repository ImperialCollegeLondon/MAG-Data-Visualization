classdef tCommand < matlab.unittest.TestCase
% TCOMMAND Unit tests for "mag.app.Command" class.

    methods (Test)

        % Test that functional with no arguments can be called.
        function noArguments(testCase)

            % Set up.
            command = mag.app.Command(Functional = @ones);

            % Exercise.
            args = command.getCellArguments();
            value = command.call();

            % Verify.
            testCase.verifyEmpty(args, "Arguments should be empty.");
            testCase.verifyEqual(value, 1, "Returned value should be ""1"".");
        end

        % Test that functional with only positional arguments can be
        % called.
        function positionalArguments(testCase)

            % Set up.
            command = mag.app.Command(Functional = @ones, PositionalArguments = {2});

            % Exercise.
            args = command.getCellArguments();
            value = command.call();

            % Verify.
            testCase.verifyEqual(args, {2}, "Arguments should match expectation.");
            testCase.verifyEqual(value, ones(2), "Returned value should match expectation.");
        end

        % Test that functional with only named arguments can be called.
        function namedArguments(testCase)

            % Set up.
            command = mag.app.Command(Functional = @ones, NamedArguments = struct(like = uint16(1)));

            % Exercise.
            args = command.getCellArguments();
            value = command.call();

            % Verify.
            testCase.verifyEqual(args, {'like', uint16(1)}, "Arguments should match expectation.");
            testCase.verifyEqual(value, uint16(1), "Returned value should match expectation.");
        end

        % Test that functional with both positional and named arguments can
        % be called.
        function positionalAndNamedArguments(testCase)

            % Set up.
            command = mag.app.Command(Functional = @ones, Positional = {2}, NamedArguments = struct(like = uint16(1)));

            % Exercise.
            args = command.getCellArguments();
            value = command.call();

            % Verify.
            testCase.verifyEqual(args, {2, 'like', uint16(1)}, "Arguments should match expectation.");
            testCase.verifyEqual(value, uint16(ones(2)), "Returned value should match expectation.");
        end

        % Test that number of in- and outputs can be extracted.
        function narginout(testCase)

            % Set up.
            command = mag.app.Command(Functional = @ones);

            % Exercise and verify.
            testCase.verifyEqual(command.NArgIn, -1, "Number of input argument should match expectation.");
            testCase.verifyEqual(command.NArgOut, 1, "Number of output argument should match expectation.");
        end
    end
end
