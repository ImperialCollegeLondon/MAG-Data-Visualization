classdef (Sealed) PackageTask < matlab.buildtool.Task
% PACKAGETASK Package code into toolbox.

    properties (TaskInput)
        % PACKAGE MATLAB package definition.
        Package matlab.mpm.Package {mustBeScalarOrEmpty}
        % MINIMUMRELEASE Minimum MATLAB release.
        MinimumRelease (1, 1) string = "R2024a"
        % ICON Path to icon.
        Icon string {mustBeScalarOrEmpty, mustBeFile}
        % EXTRAFILES Extra files to package.
        ExtraFiles (1, :) string = string.empty()
        % TOOLBOXPATH Full path to toolbox to package into.
        ToolboxPath string {mustBeScalarOrEmpty}
    end

    properties (Dependent, Hidden, TaskOutput, SetAccess = private)
        % TOOLBOXARTIFACT Toolbox packaged by task.
        ToolboxArtifact matlab.buildtool.io.File {mustBeScalarOrEmpty}
    end

    methods

        function task = PackageTask(options)

            arguments
                options.?mag.buildtool.task.PackageTask
            end

            for p = string(fieldnames(options))'
                task.(p) = options.(p);
            end
        end

        function value = get.ToolboxArtifact(task)
            value = matlab.buildtool.io.File(task.ToolboxPath);
        end
    end

    methods (Hidden, TaskAction)

        function packageToolbox(task, ~, version)
        % PACKAGETOOLBOX Package code into toolbox.

            arguments
                task (1, 1) mag.buildtool.task.PackageTask
                ~
                version (1, 1) string = task.Package.Version
            end

            toolboxOptions = matlab.addons.toolbox.ToolboxOptions( ...
                task.Package.PackageRoot, ...
                task.Package.ID, ...
                ToolboxVersion = version, ...
                ToolboxFiles = task.getToolboxFiles(), ...
                ToolboxMatlabPath = task.getMATLABPath(), ...
                OutputFile = task.ToolboxPath, ...
                MinimumMATLABRelease = task.MinimumRelease);

            if ~isempty(task.Icon)
                toolboxOptions.ToolboxImageFile = task.Icon;
            end

            toolboxOptions.SupportedPlatforms.Win64 = true;
            toolboxOptions.SupportedPlatforms.Maci64 = true;
            toolboxOptions.SupportedPlatforms.Glnxa64 = true;
            toolboxOptions.SupportedPlatforms.MatlabOnline = false;

            matlab.addons.toolbox.packageToolbox(toolboxOptions);
        end
    end

    methods (Access = private)

        function files = getToolboxFiles(task)

            files = fullfile(task.Package.PackageRoot, ["app", "src", ...
                task.ExtraFiles]);
        end

        function matlabPath = getMATLABPath(task)

            matlabPath = string(split(path(), pathsep()));

            locMAG = contains(matlabPath, task.Package.PackageRoot) & ~contains(matlabPath, "test" | "tests");
            matlabPath = matlabPath(locMAG);
        end
    end
end
