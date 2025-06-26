classdef (Abstract) AnalysisTestCase < mag.test.case.UITestCase
% ANALYSISTESTCASE Base class for all MAG analysis tests.

    properties (Access = protected)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end
end
