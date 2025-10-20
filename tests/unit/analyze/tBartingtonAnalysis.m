classdef tBartingtonAnalysis < matlab.unittest.TestCase
% TBARTINGTONANALYSIS Unit tests for "mag.bart.Analysis" class.

    methods (Test)

        % Test loading Bartington data with only 1 sensor.
        function onlyOneSensor(testCase)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "test_data");

            % Exercise.
            analysis = mag.bart.Analysis.start(Location = location);

            % Verify.
            testCase.assertNotEmpty(analysis.Results, "Analysis results should not be empty.");

            testCase.assertNotEmpty(analysis.Results.Input1, "Input 1 should exist.");
            testCase.assertNotEmpty(analysis.Results.Input2, "Input 2 should exist.");

            testCase.verifyTrue(analysis.Results.Input1.HasData, "Input 1 should have data.");
            testCase.verifyFalse(analysis.Results.Input2.HasData, "Input 1 should not have data.");

            testCase.verifyEqual(analysis.Results.Metadata.Mission, mag.meta.Mission.Bartington, "Mission metadata should be set to ""Bartington"".");
        end
    end
end
