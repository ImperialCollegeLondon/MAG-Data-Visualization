classdef (Abstract) AnalysisTestCase < matlab.unittest.TestCase
% ANALYSISTESTCASE Base class for all MAG analysis tests.

    properties (Access = protected)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestClassSetup)

        function useMATLABR2024bOrAbove(testCase)
            testCase.assumeFalse(isMATLABReleaseOlderThan("R2024b"), "Only MATLAB R2024b or later is supported for this test.");
        end
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end
end
