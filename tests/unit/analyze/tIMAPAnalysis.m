classdef tIMAPAnalysis < matlab.unittest.TestCase
% TIMAPANALYSIS Unit tests for "mag.imap.Analysis" class.

    properties (TestParameter)
        AliasName = {"mag.IMAPAnalysis", "mag.IMAPTestingAnalysis", "mag.AutomatedAnalysis"}
        EmptyPattern = {struct(Name = "EventPattern", Value = string.empty(), Property = "Events"), ...
            struct(Name = "EventPattern", Value = "", Property = "Events"), ...
            struct(Name = "MetadataPattern", Value = string.empty()), ...
            struct(Name = "SciencePattern", Value = string.empty(), Property = "Science"), ...
            struct(Name = "SciencePattern", Value = "", Property = "Science"), ...
            struct(Name = "IALiRTPattern", Value = string.empty(), Property = "IALiRT"), ...
            struct(Name = "IALiRTPattern", Value = "", Property = "IALiRT"), ...
            struct(Name = "HKPattern", Value = string.empty(), Property = "HK"), ...
            struct(Name = "HKPattern", Value = "", Property = "HK")}
    end

    methods (Test)

        % Test that aliases are defined.
        function alias(testCase, AliasName)
            testCase.verifyClass(feval(AliasName), "mag.imap.Analysis", sprintf("Alias ""%s"" should exist.", AliasName));
        end

        % Test that analysis can be run with empty patterns.
        function oneEmptyPattern(testCase, EmptyPattern)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", "imap", "fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(EmptyPattern.Name, EmptyPattern.Value, Location = location);

            % Verify.
            testCase.assertNotEmpty(analysis, compose("Analysis should not be empty for pattern ""%s""", EmptyPattern.Name));

            if isfield(EmptyPattern, "Property")
                testCase.verifyEmpty(analysis.Results.(EmptyPattern.Property), compose("No %s data should be loaded with empty pattern ""%s"".", EmptyPattern.Property, EmptyPattern.Name));
            end
        end

        % Test that analysis can be run with all empty patterns.
        function allEmptyPatterns(testCase)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "..", "..", "system", "test_data", "imap", "fob_only");

            % Exercise.
            analysis = mag.imap.Analysis.start(Location = location, ...
                EventPattern = string.empty(), ...
                MetadataPattern = string.empty(), ...
                SciencePattern = string.empty(), ...
                IALiRTPattern = string.empty(), ...
                HKPattern = string.empty());

            % Verify.
            testCase.assertNotEmpty(analysis, "Analysis should not be empty.");
            testCase.assertNotEmpty(analysis.Results, "Results should not be empty.");

            testCase.verifyEmpty(analysis.Results.Events, "Events should be empty.");
            testCase.verifyEmpty(analysis.Results.Science, "Science should be empty.");
            testCase.verifyEmpty(analysis.Results.IALiRT, "IALiRT should be empty.");
            testCase.verifyEmpty(analysis.Results.HK, "HK should be empty.");
        end
    end
end
