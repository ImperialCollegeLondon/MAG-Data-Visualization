classdef (Abstract) RequireMinMATLABRelease < matlab.unittest.TestCase
% REQUIREMINMATLABRELEASE Require a minimum MATLAB release for testing.

    properties (Abstract, Constant)
        % MINIMUMRELEASE Minimum MATLAB release required.
        MinimumRelease (1, 1) string {mag.validator.mustMatchRegex(MinimumRelease, "^[Rr][0-9]{4}[A-Za-z]$")}
    end

    methods (TestClassSetup)

        function useMinMATLABRReleaseOrAbove(testCase)

            testCase.assumeFalse(isMATLABReleaseOlderThan(testCase.MinimumRelease), ...
                compose("Only MATLAB %s or later is supported for this test.", testCase.MinimumRelease));
        end
    end
end
