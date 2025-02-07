classdef (Sealed) PackageTask < matlab.buildtool.Task
% PACKAGETASK Package code into toolbox.

    properties (Constant, Access = private)
        ToolboxUUID (1, 1) string = "69962df8-e93e-47cd-a1d6-766ad3e9da8a"
    end

    properties (TaskInput)
        % PROJECTROOT Project root folder.
        ProjectRoot (1, 1) string {mustBeFolder} = pwd()
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

            disp(compose("Project root: %s", task.ProjectRoot))
            disp(ls(task.ProjectRoot))

            toolboxOptions = matlab.addons.toolbox.ToolboxOptions(fileparts(task.ToolboxPath), task.ToolboxUUID, ...
                ToolboxName = "MAG Data Visualization", ...
                ToolboxVersion = version, ...
                Description = "Source code for MAG Data Visualization toolbox.", ...
                AuthorName = "Michele Facchinelli", ...
                AuthorCompany = "Imperial College London", ...
                ToolboxFiles = fullfile(task.ProjectRoot, ["app", "src"]), ...
                ToolboxMatlabPath = task.getMATLABPath(), ...
                OutputFile = task.ToolboxPath, ...
                MinimumMATLABRelease = "R2023b");

            toolboxOptions.SupportedPlatforms.Win64 = true;
            toolboxOptions.SupportedPlatforms.Maci64 = true;
            toolboxOptions.SupportedPlatforms.Glnxa64 = true;
            toolboxOptions.SupportedPlatforms.MatlabOnline = false;

            matlab.addons.toolbox.packageToolbox(toolboxOptions);
        end
    end

    methods (Static, Access = private)

        function matlabPath = getMATLABPath()

            matlabPath = string(split(path(), pathsep()));
            
            locMAG = contains(matlabPath, "MAG-Data-Visualization") & contains(matlabPath, ["app", "src"]);
            matlabPath = matlabPath(locMAG);
        end
    end
end
