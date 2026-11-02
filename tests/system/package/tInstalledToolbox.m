classdef (TestTags = ["System", "Parallel"]) tInstalledToolbox < matlab.unittest.TestCase
% TINSTALLEDTOOLBOX Tests that releases older than R2026b test the toolbox
% built with R2026b, rather than source code.

    methods (TestClassSetup)

        function useReleaseOlderThanR2026b(testCase)

            testCase.assumeTrue(isMATLABReleaseOlderThan("R2026b"), "Only MATLAB releases older than R2026b test the installed toolbox.");
        end
    end

    methods (Test)

        % Test that code resolves to the add-on folder.
        function codeResolvesToAddOnFolder(testCase)

            % Set up.
            s = settings();
            addOnFolder = string(s.matlab.addons.InstallationFolder.ActiveValue);

            % Exercise.
            location = string(which("mag.version"));

            % Verify.
            testCase.verifyTrue(startsWith(location, addOnFolder, IgnoreCase = true), ...
                compose("""mag.version"" should resolve to add-on folder ""%s"", not ""%s"".", addOnFolder, location));
        end
    end
end
