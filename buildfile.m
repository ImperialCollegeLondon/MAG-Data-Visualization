function plan = buildfile()
% BUILDFILE File invoked by automated build.

    % Create a plan from task functions.
    plan = buildplan();

    % Get current project.
    if isMATLABReleaseOlderThan("R2024b")

        project = matlab.project.currentProject();

        if isempty(project) || ~isequal(project.Name, "MAG Data Visualization")

            project = matlab.project.loadProject("MAGDataVisualization.prj");
            restoreProject = onCleanup(@() project.close());
        end
    else
        project = plan.Project;
    end

    % Add the "check" task to identify code issues.
    sourceFolders = ["app", "src"];

    plan("check") = matlab.buildtool.tasks.CodeIssuesTask(sourceFolders, ...
        IncludeSubfolders = true, ...
        Results = fullfile("artifacts/issues.sarif"));

    % Add the "test" task to run tests.
    testFolders = ["tests/system", "tests/unit"];

    plan("test") = matlab.buildtool.tasks.TestTask(testFolders, ...
        SourceFiles = [sourceFolders, "tests/tool"], ...
        IncludeSubfolders = true, ...
        TestResults = fullfile("artifacts/results.xml"), ...
        CodeCoverageResults = fullfile("artifacts/coverage.xml"));

    % Add the "package" task to create toolbox.
    plan("package") = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
        ProjectRoot = project.RootFolder, ...
        ToolboxPath = fullfile("artifacts/MAG Data Visualization.mltbx"));

    % Add the "clean" task to delete output of all tasks.
    plan("clean") = matlab.buildtool.tasks.CleanTask();

    % Make sure tasks run by default.
    plan.DefaultTasks = ["check", "test"];
end
