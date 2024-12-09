classdef tEventFilter < matlab.unittest.TestCase
% TEVENTFILTER Unit tests for "mag.process.EventFilter" class.

    methods (Test)

        % Test that alias is defined.
        function alias(testCase)
            testCase.verifyClass(mag.process.Filter(), "mag.process.EventFilter", "Alias ""mag.process.Filter"" should exist.");
        end
    end
end
