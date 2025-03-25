classdef (Abstract) AppTestCase < matlab.uitest.TestCase
% APPTESTCASE Base class for all MAG app tests.

    methods (TestClassSetup)

        % Skip tests on GitHub CI runner.
        function skipOnGitHub(testCase)
            testCase.assumeTrue(isempty(getenv("GITHUB_ACTIONS")), "Tests cannot run on GitHub CI runner.");
        end

        % Close all figures opened by test.
        function closeTestFigures(testCase)
            testCase.applyFixture(mag.test.fixture.CleanupFigures());
        end
    end

    methods (Access = protected)

        function copyDataToWorkingDirectory(testCase, workingDirectory, testFolder)

            [status, message] = copyfile(fullfile(workingDirectory.StartingFolder, "..", "test_data", testFolder), workingDirectory.Folder);
            testCase.assertTrue(status, sprintf("Copy of test data failed: %s", message));
        end

        function app = createAppWithCleanup(testCase, varargin)

            arguments (Output)
                app (1, 1) DataVisualization
            end

            app = DataVisualization(varargin{:});
            testCase.addTeardown(@() delete(app));
        end

        function verifyAppUIElementStatus(testCase, app, status, elements)

            arguments
                testCase
                app (1, 1) DataVisualization
                status (1, 1) matlab.lang.OnOffSwitchState
                elements (1, :) string = ["ExportFormatDropDown", "ExportButton", "ExportSettingsPanel", "ShowFiguresButton"]
            end

            for e = elements

                testCase.verifyEqual(app.(e).Enable, status, ...
                    compose("Status of element ""%s"" should be %s.", e, status));
            end
        end
    end
end
