classdef (Sealed) PackageTask < matlab.buildtool.Task
% PACKAGETASK Package code into toolbox.

    properties (Constant)
        ToolboxName (1, 1) string = mag.internal.getPackageDetails("DisplayName")
    end

    properties (Constant, Access = private)
        ToolboxUUID (1, 1) string = "69962df8-e93e-47cd-a1d6-766ad3e9da8a"
    end

    properties (TaskInput)
        % PACKAGEROOT Package root folder.
        PackageRoot (1, 1) string {mustBeFolder} = pwd()
        % TOOLBOXVERSION Toolbox configuration project template.
        ToolboxVersion (1, 1) string = mag.version()
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
                version (1, 1) string = task.ToolboxVersion
            end

            toolboxOptions = matlab.addons.toolbox.ToolboxOptions(task.PackageRoot, task.ToolboxUUID, ...
                ToolboxName = mag.buildtool.task.PackageTask.ToolboxName, ...
                ToolboxVersion = version, ...
                Description = mag.internal.getPackageDetails("Description"), ...
                ToolboxFiles = task.getToolboxFiles(), ...
                ToolboxMatlabPath = task.getMATLABPath(), ...
                ToolboxImageFile = fullfile(task.PackageRoot, "icons", "logo.png"), ...
                OutputFile = task.ToolboxPath, ...
                MinimumMATLABRelease = "R2024a");

            toolboxOptions.SupportedPlatforms.Win64 = true;
            toolboxOptions.SupportedPlatforms.Maci64 = true;
            toolboxOptions.SupportedPlatforms.Glnxa64 = true;
            toolboxOptions.SupportedPlatforms.MatlabOnline = false;

            matlab.addons.toolbox.packageToolbox(toolboxOptions);
        end
    end

    methods (Access = private)

        function files = getToolboxFiles(task)

            files = fullfile(task.PackageRoot, ["app", "src", ...
                fullfile("resources", "extensions.json"), ...
                fullfile("icons", "mag.png")]);
        end
    end

    methods (Static, Access = private)

        function matlabPath = getMATLABPath()

            matlabPath = string(split(path(), pathsep()));

            locMAG = contains(matlabPath, "MAG-Data-Visualization") & ~contains(matlabPath, ["tests"]);
            matlabPath = matlabPath(locMAG);
        end
    end
end
