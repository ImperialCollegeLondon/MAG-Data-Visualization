classdef (TestTags = "System") tToolbox < matlab.unittest.TestCase & mag.test.mixin.RequireMinMATLABRelease
% TTOOLBOX Tests for installation of MAG Data Visualization toolbox.

    properties (Constant)
        MinimumRelease = "R2026b"
    end

    properties (Constant, Access = private)
        PackageRoot (1, 1) string = fullfile(fileparts(mfilename("fullpath")), "..", "..", "..")
        ToolboxName (1, 1) string = mag.internal.getPackageDetails("DisplayName")
    end

    properties (TestParameter)
        Version = {"1.0.1", "2.3.1"}
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

            unpackFolder = testCase.createTemporaryFolder();
            unzip(task.ToolboxArtifact.Path, unpackFolder);

            readmePath = fullfile(unpackFolder, "fsroot", "README.md");
            testCase.assertTrue(isfile(readmePath), "Root README should be packaged.");
            testCase.verifyEqual(fileread(readmePath), fileread(fullfile(testCase.PackageRoot, "README.md")));
        end

        function packageReadmeMetadata(testCase)

            unpackFolder = testCase.packageAndUnpackToolbox();

            metadata = jsondecode(fileread(fullfile(unpackFolder, "fsroot", "resources", "mpackage.json")));
            testCase.assertTrue(isfield(metadata, "readme"), "Package manifest should declare a README.");
            testCase.verifyEqual(string(metadata.readme), "README.md");
        end

        % Test that add-on has a description, as package definition no
        % longer has one.
        function packageDescription(testCase)

            % Exercise.
            unpackFolder = testCase.packageAndUnpackToolbox();

            % Verify.
            properties = fileread(fullfile(unpackFolder, "metadata", "addonProperties.xml"));
            description = extractBetween(string(properties), "<description>", "</description>");

            testCase.verifyEqual(strip(description), string(mag.internal.getPackageDetails("Summary")), "Add-on description should be package summary.");
        end

        % Test that only package folders that are packaged are on the path
        % of the toolbox.
        function packageMATLABPath(testCase)

            % Set up.
            folders = [matlab.mpm.Package(testCase.PackageRoot).Folders.Path];

            % Exercise.
            unpackFolder = testCase.packageAndUnpackToolbox();

            % Verify.
            configuration = fileread(fullfile(unpackFolder, "metadata", "configuration.xml"));
            matlabPath = extractBetween(string(configuration), "<matlabPath>", "</matlabPath>");

            testCase.verifyTrue(all(ismember("/" + folders(~startsWith(folders, "tests")), matlabPath)), "Source folders should be on the path.");
            testCase.verifyFalse(any(contains(matlabPath, "tests")), "Test folders should not be on the path.");
        end

        % Test that files that are not part of the code are not packaged.
        function packageExcludesEditorFiles(testCase)

            % Set up.
            backupFile = fullfile(testCase.PackageRoot, "src", "tToolbox.asv");

            fclose(fopen(backupFile, "w"));
            testCase.addTeardown(@() delete(backupFile));

            % Exercise.
            unpackFolder = testCase.packageAndUnpackToolbox();

            % Verify.
            testCase.verifyEmpty(dir(fullfile(unpackFolder, "fsroot", "**", "*.asv")), "Editor backup files should not be packaged.");
        end

        % Test that toolbox can be installed.
        function installToolbox(testCase)

            % Set up.
            testCase.assumeEmpty(mpmlist(testCase.ToolboxName), "MAG Data Visualization installed as a MATLAB package.");
            task = testCase.createPackageTask();

            % Exercise.
            task.packageToolbox();
            testCase.addTeardown(@() testCase.cleanUpToolbox(task));

            % Verify.
            testCase.assertTrue(isfile(task.ToolboxArtifact.Path), "Toolbox should be generated.");

            matlab.addons.install(task.ToolboxArtifact.Path);
            testCase.addTeardown(@() matlab.addons.uninstall(testCase.ToolboxName));

            addOns = matlab.addons.installedAddons();
            locMAG = addOns.Name == mag.internal.getPackageDetails("DisplayName");

            testCase.verifyEqual(addOns{locMAG, "Version"}, mag.version(), "Toolbox version should be equal to MAG version.");
        end
    end

    methods (Access = private)

        function task = createPackageTask(testCase)

            task = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
                Package = matlab.mpm.Package(testCase.PackageRoot), ...
                ToolboxPath = fullfile(testCase.createTemporaryFolder(), "MAG Data Visualization.mltbx"));
        end

        function unpackFolder = packageAndUnpackToolbox(testCase)

            task = testCase.createPackageTask();
            testCase.addTeardown(@() testCase.cleanUpToolbox(task));

            task.packageToolbox([]);

            unpackFolder = testCase.createTemporaryFolder();
            unzip(task.ToolboxArtifact.Path, unpackFolder);
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
