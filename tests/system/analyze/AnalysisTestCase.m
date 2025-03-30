classdef (Abstract) AnalysisTestCase < matlab.unittest.TestCase
% ANALYSISTESTCASE Base class for all MAG analysis tests.

    properties (Access = protected)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestClassSetup)

        function useMATLABR2024bOrAbove(testCase)
            testCase.assumeTrue(matlabRelease().Release >= "R2024b", "Only MATLAB older than R2024b is supported for this test.");
        end
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end
end
