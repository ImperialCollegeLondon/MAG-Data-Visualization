classdef (Abstract) UITestCase < matlab.uitest.TestCase
% UITESTCASE Base class for all MAG UI tests.

    methods (TestClassSetup)

        % Do not run tests in R2024a and older as not all functionality is
        % supported.
        function useMATLABR2024bOrAbove(testCase)
            testCase.assumeFalse(isMATLABReleaseOlderThan("R2024b"), "Only MATLAB R2024b or later is supported for this test.");
        end
    end
end
