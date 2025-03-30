classdef (Abstract) AnalysisTestCase < matlab.unittest.TestCase
% ANALYSISTESTCASE Base class for all MAG analysis tests.

    methods (TestClassSetup)

        function skipOnGitHub(testCase)
            testCase.assumeTrue(isempty(getenv("GITHUB_ACTIONS")), "Tests cannot run on GitHub CI runner.");
        end

        function useMATLABR2024bOrAbove(testCase)
            testCase.assumeTrue(matlabRelease().Release >= "R2024b", "Only MATLAB older than R2024b is supported for this test.");
        end
    end
end
