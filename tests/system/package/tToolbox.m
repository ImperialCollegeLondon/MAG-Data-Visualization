classdef tToolbox < matlab.unittest.TestCase
% TTOOLBOX Tests for installation of MAG Data Visualization toolbox.

    properties (Constant, Access = private)
        PackageRoot (1, 1) string = fullfile(fileparts(mfilename("fullpath")), "..", "..", "..")
    end

    properties (TestParameter)
        Version = {"1.0.1", "2.3.1"}
    end

    methods (TestClassSetup)

        function useMATLABR2025aOrAbove(testCase)
            testCase.assumeFalse(isMATLABReleaseOlderThan("R2025a"), "Only MATLAB R2025a or later is supported for this test.");
        end

        function checkMATLABPackage(testCase)

            % MATLAB will still execute this method, even if the above
            % check fails.
            if ~isMATLABReleaseOlderThan("R2025a")
                testCase.assumeEmpty(mpmlist(mag.buildtool.task.PackageTask.ToolboxName), "MAG Data Visualization installed as a MATLAB package.");
            end
        end
    end

    methods (Test)

        % Test that toolbox can be packaged.
        function packageToolbox(testCase, Version)

            % Set up.
            task = testCase.createPackageTask();

            % Exercise.
            task.packageToolbox([], Version);
            testCase.addTeardown(@() testCase.cleanUpToolbox(task));

            % Verify.
            testCase.verifyTrue(isfile(task.ToolboxArtifact.Path), "Toolbox should be generated.");
        end

        % Test that toolbox can be installed.
        function installToolbox(testCase)

            % Set up.
            task = testCase.createPackageTask();

            % Exercise.
            task.packageToolbox();
            testCase.addTeardown(@() testCase.cleanUpToolbox(task));

            % Verify.
            testCase.assertTrue(isfile(task.ToolboxArtifact.Path), "Toolbox should be generated.");

            matlab.addons.install(task.ToolboxArtifact.Path);
            testCase.addTeardown(@() matlab.addons.uninstall(mag.buildtool.task.PackageTask.ToolboxName));

            addOns = matlab.addons.installedAddons();
            locMAG = addOns.Name == mag.internal.getPackageDetails("DisplayName");

            testCase.verifyEqual(addOns{locMAG, "Version"}, mag.version(), "Toolbox version should be equal to MAG version.");
        end
    end

    methods (Access = private)

        function task = createPackageTask(testCase)

            task = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
                PackageRoot = testCase.PackageRoot, ...
                ToolboxPath = fullfile(testCase.PackageRoot, "artifacts", "MAG Data Visualization.mltbx"));
        end
    end

    methods (Static, Access = private)

        function cleanUpToolbox(task)

            if isfile(task.ToolboxArtifact.Path)
                delete(task.ToolboxArtifact.Path);
            end
        end
    end
end
