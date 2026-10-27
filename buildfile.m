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

    % Add the "install" task to install support packages (".mltbx" files)
    % in the root folder. Since R2026b, installations may not persist
    % across MATLAB sessions, so run this task in the same session as the
    % tests.
    plan("install") = matlab.buildtool.Task(Description = "Install support packages in root folder", ...
        Actions = @installSupportPackages);

    % Add the "check" task to identify code issues.
    sourceFolders = ["app", "src"];

    plan("check") = matlab.buildtool.tasks.CodeIssuesTask(sourceFolders, ...
        IncludeSubfolders = true, ...
        Results = fullfile("artifacts/issues.sarif"));

    % Add the "test" tasks to run unit and system tests. Tests tagged
    % "Parallel" can run on a parallel pool, using "buildtool test:parallel
    % -parallel". Tests tagged "Interactive" interact with visible UI
    % windows, and only run with "buildtool test:ui". All other tests must
    % run serially.
    import matlab.unittest.selectors.HasTag;

    testFolders = ["tests/system", "tests/unit"];
    testOptions = {"SourceFiles", [sourceFolders, "tests/tool"], "IncludeSubfolders", true};

    plan("test:parallel") = matlab.buildtool.tasks.TestTask(testFolders, testOptions{:}, ...
        Description = "Run tests that support parallel execution", ...
        Tag = "Parallel", ...
        TestResults = fullfile("artifacts/results-parallel.xml"), ...
        CodeCoverageResults = fullfile("artifacts/coverage-parallel.mat"));

    plan("test:serial") = matlab.buildtool.tasks.TestTask(testFolders, testOptions{:}, ...
        Description = "Run tests that require serial execution", ...
        Selector = ~HasTag("Parallel") & ~HasTag("Interactive"), ...
        TestResults = fullfile("artifacts/results-serial.xml"), ...
        CodeCoverageResults = fullfile("artifacts/coverage-serial.mat"));

    plan("test:ui") = matlab.buildtool.tasks.TestTask(testFolders, testOptions{:}, ...
        Description = "Run tests that interact with visible UI windows", ...
        Tag = "Interactive", ...
        TestResults = fullfile("artifacts/results-ui.xml"), ...
        CodeCoverageResults = fullfile("artifacts/coverage-ui.mat"));

    for taskName = ["test:parallel", "test:serial", "test:ui"]
        plan(taskName).Actions = [plan("install").Actions, plan(taskName).Actions];
    end

    if ~isMATLABReleaseOlderThan("R2025a")

        plan("test:parallel").RunOnlyImpactedTests = true;
        plan("test:serial").RunOnlyImpactedTests = true;
        plan("test:ui").RunOnlyImpactedTests = true;
    end

    % Add the "coverage" task to merge code coverage of all test tasks.
    % Inputs are specified as paths, so that test tasks are not inferred as
    % dependencies, and can run separately.
    plan("coverage") = matlab.buildtool.Task(Description = "Merge code coverage results", ...
        Actions = @mergeCoverage, ...
        Inputs = fullfile("artifacts", ["coverage-parallel.mat", "coverage-serial.mat", "coverage-ui.mat"]), ...
        Outputs = fullfile("artifacts/coverage.xml"));

    % Add the "perf" task to measure performance. Task always runs, as
    % measurements change between runs.
    plan("perf") = matlab.buildtool.Task(Description = "Run performance tests", ...
        Actions = @runPerformanceTests);

    % Add the "package" task to create toolbox.
    if ~isMATLABReleaseOlderThan("R2025a")

        plan("package") = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
            Package = matlab.mpm.Package(plan.RootFolder), ...
            Icon = fullfile(plan.RootFolder, "icons", "logo.png"), ...
            ExtraFiles = [fullfile("resources", "extensions.json"), fullfile("icons", "mag.png")], ...
            ToolboxPath = fullfile("artifacts/MAG Data Visualization.mltbx"));
    end

    % Add the "clean" task to delete output of all tasks.
    plan("clean") = matlab.buildtool.tasks.CleanTask();

    % Make sure tasks run by default. UI tests are excluded, as they open
    % windows that take focus.
    plan.DefaultTasks = ["check", "test:parallel", "test:serial", "coverage"];
end

function installSupportPackages(context)
% INSTALLSUPPORTPACKAGES Install all support packages (".mltbx" files) in
% the root folder.

    toolboxes = dir(fullfile(context.Plan.RootFolder, "*.mltbx"));

    for t = toolboxes'

        disp("Installing """ + t.name + """...");
        matlab.addons.install(fullfile(t.folder, t.name));
    end
end

function mergeCoverage(context)
% MERGECOVERAGE Merge code coverage results of test tasks into a single
% Cobertura report.

    coverageFiles = context.Task.Inputs.paths();
    coverageFiles = coverageFiles(isfile(coverageFiles));

    if isempty(coverageFiles)
        error("mag:buildtool:NoCoverage", "No code coverage results found. Run ""test"" task first.");
    end

    coverageResults = load(coverageFiles(1), "coverage").coverage;

    for file = coverageFiles(2:end)
        coverageResults = coverageResults + load(file, "coverage").coverage;
    end

    generateCoberturaReport(coverageResults, context.Task.Outputs.paths());
end

function runPerformanceTests(context)
% RUNPERFORMANCETESTS Measure performance and save summary of results.

    results = runperf(fullfile(context.Plan.RootFolder, "tests", "performance"), IncludeSubfolders = true);
    summary = sampleSummary(results);

    disp(summary);

    artifactsFolder = fullfile(context.Plan.RootFolder, "artifacts");

    if ~isfolder(artifactsFolder)
        mkdir(artifactsFolder);
    end

    writetable(summary, fullfile(artifactsFolder, "performance.csv"));

    context.assertTrue(all([results.Valid]), "All performance tests should complete successfully.");
end
