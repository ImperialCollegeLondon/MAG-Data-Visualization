classdef tCodeAnalyzerConfiguration < matlab.unittest.TestCase & mag.test.mixin.RequireMinMATLABRelease
% TCODEANALYZERCONFIGURATION Tests for code analyzer configuration JSON
% file.

    properties (Constant)
        MinimumRelease = "R2025a"
    end

    properties (Constant, Access = public)
        ConfigurationFile = fullfile(fileparts(mfilename("fullpath")), "..", "..", "..", "resources", "codeAnalyzerConfiguration.json")
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
