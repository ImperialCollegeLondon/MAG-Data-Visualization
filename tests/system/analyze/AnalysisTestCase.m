classdef (Abstract) AnalysisTestCase < matlab.unittest.TestCase & mag.test.mixin.RequireMinMATLABRelease
% ANALYSISTESTCASE Base class for all MAG analysis tests.

    properties (Constant)
        MinimumRelease = "R2024b"
    end

    properties (Access = protected)
        WorkingDirectory (1, 1) matlab.unittest.fixtures.WorkingFolderFixture
    end

    methods (TestMethodSetup)

        function setUpWorkingDirectory(testCase)
            testCase.WorkingDirectory = testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture());
        end
    end

    methods (Access = protected)

        function copyDataToWorkingDirectory(testCase, testFolder)
            mag.test.DataTestUtilities.copySystemTestData(testCase, testFolder, testCase.WorkingDirectory.Folder);
        end
    end
end
