classdef tCodeAnalyzerConfiguration < matlab.unittest.TestCase
% TCODEANALYZERCONFIGURATION Tests for code analyzer configuration JSON
% file.

    properties (Constant, Access = public)
        ConfigurationFile = fullfile(fileparts(mfilename("fullpath")), "..", "..", "..", "resources", "codeAnalyzerConfiguration.json")
    end

    methods (TestClassSetup)

        function useMATLABR2025aOrAbove(testCase)
            testCase.assumeFalse(isMATLABReleaseOlderThan("R2025a"), "Only MATLAB R2025a or later is supported for this test.");
        end
    end

    methods (Test)

        function validConfiguration(testCase)

            % Set up.
            testCase.assertThat(testCase.ConfigurationFile, matlab.unittest.constraints.IsFile(), "Configuration file should exist.");

            % Exercise.
            results = matlab.codeanalysis.validateConfiguration(testCase.ConfigurationFile);

            % Verify.
            testCase.verifyEmpty(results, "Configuration file should be valid.");
        end
    end
end
