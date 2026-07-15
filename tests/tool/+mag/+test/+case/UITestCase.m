classdef (Abstract) UITestCase < matlab.uitest.TestCase & mag.test.mixin.RequireMinMATLABRelease
% UITESTCASE Base class for all MAG UI tests.

    properties (Constant)
        MinimumRelease = "R2024b"
    end

    methods (TestClassSetup)

        function screenshotOnFailure(testCase)

            if mag.test.isGitHub()
                testCase.onFailure(matlab.unittest.diagnostics.ScreenshotDiagnostic(Prefix = "mag_test_failure_"));
            end
        end
    end
end
