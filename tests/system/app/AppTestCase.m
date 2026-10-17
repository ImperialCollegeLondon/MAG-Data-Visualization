classdef (Abstract) AppTestCase < mag.test.case.UITestCase & mag.test.case.GraphicsTestCase
% APPTESTCASE Base class for all MAG app tests.

    properties (Constant, Access = protected)
        % TASKTIMEOUT Maximum time (in seconds) to wait for background
        % tasks.
        TaskTimeout (1, 1) double = 300
    end

    methods (TestClassSetup)

        % Background tasks may start a process-based pool, if not
        % supported on threads.
        function cleanupParallelPool(testCase)
            testCase.applyFixture(mag.test.fixture.CleanupParallelPool());
        end
    end

    methods (Access = protected)

        function processData(testCase, app)
        % PROCESSDATA Press "Process Data" button and wait for processing
        % to complete.

            testCase.press(app.ProcessDataButton);
            testCase.waitForTasks(app);
        end

        function waitForTasks(testCase, app)
        % WAITFORTASKS Wait for app background tasks to complete.

            testCase.assertTrue(app.waitForTasks(testCase.TaskTimeout), ...
                compose("Background tasks should complete within %d seconds.", testCase.TaskTimeout));
        end

        function copyDataToWorkingDirectory(testCase, workingDirectory, testFolder)
            mag.test.DataTestUtilities.copySystemTestData(testCase, testFolder, workingDirectory.Folder);
        end

        function app = createAppWithCleanup(testCase, varargin)

            arguments (Output)
                app (1, 1) DataVisualization
            end

            app = DataVisualization(varargin{:});
            app.UIFigure.Visible = "on";

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
