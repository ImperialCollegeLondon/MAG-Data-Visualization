classdef (TestTags = ["System", "Parallel"]) tTestTags < matlab.unittest.TestCase
% TTESTTAGS Tests that all tests are tagged consistently, so that they can
% be selected by tag.

    properties (Constant, Access = private)
        TestsRoot (1, 1) string = fullfile(fileparts(mfilename("fullpath")), "..", "..")
        CategoryTags (1, :) string = ["Unit", "System", "Performance"]
    end

    properties (TestParameter)
        Category = struct(Unit = struct(Folder = "unit", Tag = "Unit"), ...
            System = struct(Folder = "system", Tag = "System"), ...
            Performance = struct(Folder = "performance", Tag = "Performance"))
    end

    methods (Test)

        % Test that all tests in a folder are tagged with the folder
        % category, and with no other category.
        function categoryTag(testCase, Category)

            % Set up.
            suite = testsuite(fullfile(testCase.TestsRoot, Category.Folder), IncludeSubfolders = true);
            testCase.assumeNotEmpty(suite, "No tests found.");

            % Exercise and verify.
            for test = suite

                categories = intersect(string(test.Tags), testCase.CategoryTags);
                testCase.verifyEqual(categories, Category.Tag, compose("Test ""%s"" should only have category tag ""%s"".", test.Name, Category.Tag));
            end
        end

        % Test that performance tests do not run in parallel, as other
        % processes would add noise to measurements.
        function performanceNotParallel(testCase)

            % Set up.
            suite = testsuite(fullfile(testCase.TestsRoot, "performance"), IncludeSubfolders = true, Tag = "Parallel");

            % Exercise and verify.
            testCase.verifyEmpty(suite, "Performance tests should not be tagged ""Parallel"".");
        end
    end
end
