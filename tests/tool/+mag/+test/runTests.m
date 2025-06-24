function testResults = runTests()

    root = mfilename("fullpath");
    root = fullfile(fileparts(root), "..", "..", "..");

    testResults = runtests(root, IncludeSubfolders = true, ReportCoverageFor = ["app", "src"]);
end
