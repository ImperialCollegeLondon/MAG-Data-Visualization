classdef (Sealed) PackageTask < matlab.buildtool.Task
% PACKAGETASK Package code into toolbox.

    properties (TaskInput)
        % PACKAGE MATLAB package definition.
        Package matlab.mpm.Package {mustBeScalarOrEmpty}
        % MINIMUMRELEASE Minimum MATLAB release.
        MinimumRelease (1, 1) string = "R2025a"
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

    properties (Constant, Access = private)
        % SOURCEFOLDERS Folders of code to package.
        SourceFolders (1, :) string = ["app", "src"]
        % EXCLUDEDFILES File name endings not to package.
        ExcludedFiles (1, :) string = [".asv", ".DS_Store"]
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

            % Specify both minimum and maximum release, so that release
            % compatibility is not parsed from package definition. Also
            % specify description, even if hidden since R2026b, as the
            % add-on description is otherwise empty.
            toolboxOptions = matlab.addons.toolbox.ToolboxOptions( ...
                task.Package.PackageRoot, ...
                task.Package.ID, ...
                ToolboxVersion = version, ...
                Summary = task.Package.Summary, ...
                Description = task.Package.Summary, ...
                Readme = fullfile(task.Package.PackageRoot, "README.md"), ...
                ToolboxFiles = task.getToolboxFiles(), ...
                ToolboxMatlabPath = task.getMATLABPath(), ...
                OutputFile = task.ToolboxPath, ...
                MinimumMATLABRelease = task.MinimumRelease, ...
                MaximumMATLABRelease = "");

            if ~isempty(task.Icon)
                toolboxOptions.ToolboxImageFile = task.Icon;
            end

            toolboxOptions.SupportedPlatforms.Win64 = true;
            toolboxOptions.SupportedPlatforms.Mac = true;
            toolboxOptions.SupportedPlatforms.Glnxa64 = true;
            toolboxOptions.SupportedPlatforms.MatlabOnline = false;

            matlab.addons.toolbox.packageToolbox(toolboxOptions);
        end
    end

    methods (Access = private)

        function files = getToolboxFiles(task)

            root = task.Package.PackageRoot;

            sourceFiles = arrayfun(@(f) dir(fullfile(root, f, "**", "*")), task.SourceFolders, UniformOutput = false);
            sourceFiles = vertcat(sourceFiles{:});
            sourceFiles = sourceFiles(~[sourceFiles.isdir] & ~endsWith({sourceFiles.name}, task.ExcludedFiles));

            files = [fullfile(string({sourceFiles.folder}), string({sourceFiles.name})), ...
                fullfile(root, ["README.md", task.ExtraFiles])];
        end

        function matlabPath = getMATLABPath(task)

            % Only keep package folders that are packaged, as others (e.g.,
            % test tools) do not exist in the toolbox.
            folders = [task.Package.Folders.Path];
            folders = folders(ismember(extractBefore(folders + "/", "/"), task.SourceFolders));

            matlabPath = fullfile(task.Package.PackageRoot, folders);
        end
    end
end
