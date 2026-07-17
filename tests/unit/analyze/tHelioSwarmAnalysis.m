classdef tHelioSwarmAnalysis < matlab.unittest.TestCase
% THELIOSWARMANALYSIS Unit tests for "mag.hs.Analysis" class.

    methods (Test)

        % Test that selecting iDPU input source changes scale factors.
        function iDPU_scaleFactors(testCase)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "test_data");

            % Exercise.
            idpuAnalysis = mag.hs.Analysis.start(Location = location, InputSource = "iDPU");

            % Verify.
            testCase.verifyEqual(idpuAnalysis.ScienceProcessing.ExtraScaling, (1 / 2^8) * (15/16)^2, ...
                "Extra scale factor scaling should match iDPU expectation.");

        end
    end
end
