function testResults = runTests(options)
% RUNTESTS Run MAG tests selected by tag.
%
%   RUNTESTS() runs all unit and system tests.
%
%   RUNTESTS(Tag = TAG) runs only tests with any of the specified tags,
%   e.g., "Unit", "System" or "Performance". Performance tests run once,
%   as regular tests; use "runperf" or "buildtool perf" to measure them.
%
%   RUNTESTS(UseParallel = true) runs tests tagged "Parallel" on a parallel
%   pool, and all other tests serially.
%
%   RUNTESTS(ReportCoverage = true) generates an HTML code coverage report
%   for app and source code in "artifacts/coverage".

    arguments (Input)
        options.Tag (1, :) string {mustBeMember(options.Tag, ["Unit", "System", "Performance"])} = ["Unit", "System"]
        options.UseParallel (1, 1) logical = false
        options.ReportCoverage (1, 1) logical = false
    end

    arguments (Output)
        testResults (1, :) matlab.unittest.TestResult
    end

    import matlab.unittest.selectors.HasTag;

    root = fullfile(fileparts(mfilename("fullpath")), "..", "..", "..", "..");

    selector = HasTag(options.Tag(1));

    for tag = options.Tag(2:end)
        selector = selector | HasTag(tag);
    end

    suite = testsuite(fullfile(root, "tests"), IncludeSubfolders = true);
    suite = suite.selectIf(selector);

    if options.UseParallel

        isParallel = HasTag("Parallel");

        [parallelRunner, parallelCoverage] = createRunner(root, options.ReportCoverage);
        [serialRunner, serialCoverage] = createRunner(root, options.ReportCoverage);

        testResults = [parallelRunner.runInParallel(suite.selectIf(isParallel)), ...
            serialRunner.run(suite.selectIf(~isParallel))];

        coverage = [parallelCoverage, serialCoverage];
    else

        [runner, coverage] = createRunner(root, options.ReportCoverage);
        testResults = runner.run(suite);
    end

    if options.ReportCoverage

        coverageResults = coverage(1).Result;

        for c = coverage(2:end)
            coverageResults = coverageResults + c.Result;
        end

        generateHTMLReport(coverageResults, fullfile(root, "artifacts", "coverage"));
    end
end

function [runner, coverage] = createRunner(root, reportCoverage)
% CREATERUNNER Create test runner, optionally collecting code coverage.

    runner = matlab.unittest.TestRunner.withTextOutput();
    coverage = matlab.unittest.plugins.codecoverage.CoverageResult.empty();

    if reportCoverage

        coverage = matlab.unittest.plugins.codecoverage.CoverageResult();
        runner.addPlugin(matlab.unittest.plugins.CodeCoveragePlugin.forFolder(fullfile(root, ["app", "src"]), ...
            IncludingSubfolders = true, Producing = coverage));
    end
end
