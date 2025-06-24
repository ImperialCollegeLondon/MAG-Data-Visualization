function testResults = runTests()
% RUNTESTS Run all MAG tests with coverage.

    root = mfilename("fullpath");
    root = fullfile(fileparts(root), "..", "..", "..");

    testResults = runtests(root, IncludeSubfolders = true, ReportCoverageFor = ["app", "src"]);
end
