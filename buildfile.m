function plan = buildfile()
% BUILDFILE File invoked by automated build.

    plan = buildplan();

    if isMATLABReleaseOlderThan("R2025a")

        warning("mag:buildtool:Path", "MATLAB release ""%s"" not supported for development purposes. " + ...
            "Adding all folders to the path for testing purposes.", matlabRelease().Release);

        % Brute-force add all folders to the path.
        addpath(genpath(plan.RootFolder));
    else

        % Open package if not already open.
        package = matlab.mpm.Package(plan.RootFolder);

        if ~package.Installed
            addpath(join(fullfile(plan.RootFolder, [package.Folders.Path]), pathsep()));
        end
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

    if ~isMATLABReleaseOlderThan("R2025a")
        plan("test").RunOnlyImpactedTests = true;
    end

    % Add the "package" task to create toolbox.
    plan("package") = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
        PackageRoot = plan.RootFolder, ...
        ToolboxPath = fullfile("artifacts/MAG Data Visualization.mltbx"));

    % Add the "clean" task to delete output of all tasks.
    plan("clean") = matlab.buildtool.tasks.CleanTask();

    % Make sure tasks run by default.
    plan.DefaultTasks = ["check", "test"];
end
