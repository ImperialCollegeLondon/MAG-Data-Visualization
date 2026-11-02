function plan = buildfile()
% BUILDFILE File invoked by automated build.

    plan = buildplan();

    % Fail if any test cannot be loaded. By default, it is only excluded
    % with a warning, so the build passes with fewer tests.
    warning("error", "MATLAB:unittest:TestSuite:FileExcluded");

    % Only R2026b and above can read the package definition. Older releases
    % test the toolbox built with R2026b, so source code must not be added
    % to the path, or tests would run on it instead of the installed
    % toolbox.
    useSource = ~isMATLABReleaseOlderThan("R2026b");

    if useSource

        % Open package if not already open.
        package = matlab.mpm.Package(plan.RootFolder);

        if ~package.Installed
            addpath(join(fullfile(plan.RootFolder, [package.Folders.Path]), pathsep()));
        end
    else

        addpath(fullfile(plan.RootFolder, "tests", "tool"));

        % Test tasks find their tests before running any action, so the
        % toolbox must be installed now, as many tests need it to load.
        installToolboxes(plan.RootFolder);
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
    % windows, and only run with "buildtool test:ui", which logs each test
    % as it starts, so that any test that stalls can be identified. All
    % other tests must run serially.
    import matlab.unittest.selectors.HasTag;

    testFolders = ["tests/system", "tests/unit"];
    testOptions = {"IncludeSubfolders", true};
    coverageOptions = struct(parallel = {{}}, serial = {{}}, ui = {{}});

    % Code coverage can only be measured on source code.
    if useSource

        testOptions = [testOptions, {"SourceFiles", [sourceFolders, "tests/tool"]}];

        coverageOptions.parallel = {"CodeCoverageResults", fullfile("artifacts/coverage-parallel.mat")};
        coverageOptions.serial = {"CodeCoverageResults", fullfile("artifacts/coverage-serial.mat")};
        coverageOptions.ui = {"CodeCoverageResults", fullfile("artifacts/coverage-ui.mat")};
    end

    plan("test:parallel") = matlab.buildtool.tasks.TestTask(testFolders, testOptions{:}, coverageOptions.parallel{:}, ...
        Description = "Run tests that support parallel execution", ...
        Tag = "Parallel", ...
        TestResults = fullfile("artifacts/results-parallel.xml"));

    plan("test:serial") = matlab.buildtool.tasks.TestTask(testFolders, testOptions{:}, coverageOptions.serial{:}, ...
        Description = "Run tests that require serial execution", ...
        Selector = ~HasTag("Parallel") & ~HasTag("Interactive"), ...
        TestResults = fullfile("artifacts/results-serial.xml"));

    plan("test:ui") = matlab.buildtool.tasks.TestTask(testFolders, testOptions{:}, coverageOptions.ui{:}, ...
        Description = "Run tests that interact with visible UI windows", ...
        Tag = "Interactive", ...
        OutputDetail = "detailed", ...
        TestResults = fullfile("artifacts/results-ui.xml"));

    for taskName = ["test:parallel", "test:serial", "test:ui"]
        plan(taskName).Actions = [plan("install").Actions, plan(taskName).Actions];
    end

    % Add the "coverage" task to merge code coverage of all test tasks.
    % Inputs are specified as paths, so that test tasks are not inferred as
    % dependencies, and can run separately.
    if useSource

        plan("coverage") = matlab.buildtool.Task(Description = "Merge code coverage results", ...
            Actions = @mergeCoverage, ...
            Inputs = fullfile("artifacts", ["coverage-parallel.mat", "coverage-serial.mat", "coverage-ui.mat"]), ...
            Outputs = fullfile("artifacts/coverage.xml"));
    end

    % Add the "perf" task to measure performance. Task always runs, as
    % measurements change between runs.
    plan("perf") = matlab.buildtool.Task(Description = "Run performance tests", ...
        Actions = @runPerformanceTests);

    % Add the "package" task to create toolbox.
    if useSource

        plan("package") = mag.buildtool.task.PackageTask(Description = "Package code into toolbox", ...
            Package = package, ...
            Icon = fullfile(plan.RootFolder, "icons", "logo.png"), ...
            ExtraFiles = [fullfile("resources", "extensions.json"), fullfile("icons", "mag.png")], ...
            ToolboxPath = fullfile("artifacts/MAG Data Visualization.mltbx"));
    end

    % Add the "clean" task to delete output of all tasks.
    plan("clean") = matlab.buildtool.tasks.CleanTask();

    % Make sure tasks run by default. UI tests are excluded, as they open
    % windows that take focus.
    plan.DefaultTasks = ["check", "test:parallel", "test:serial"];

    if useSource
        plan.DefaultTasks = [plan.DefaultTasks, "coverage"];
    end
end

function installSupportPackages(context)
% INSTALLSUPPORTPACKAGES Install all support packages (".mltbx" files) in
% the root folder.

    installToolboxes(context.Plan.RootFolder);
end

function installToolboxes(folder)
% INSTALLTOOLBOXES Install all toolboxes (".mltbx" files) in a folder.

    toolboxes = dir(fullfile(folder, "*.mltbx"));

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
