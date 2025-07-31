classdef tHelioSwarmAnalysis < matlab.unittest.TestCase
% THELIOSWARMANALYSIS Unit tests for "mag.hs.Analysis" class.

    methods (Test)

        % Test that selecting iDPU input source changes scale factors.
        function iDPU_scaleFactors(testCase)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "test_data");

            % Exercise.
            uartAnalysis = mag.hs.Analysis.start(Location = location, InputSource = "UART");
            idpuAnalysis = mag.hs.Analysis.start(Location = location, InputSource = "iDPU");

            % Verify.
            testCase.verifyEqual(uartAnalysis.ScienceProcessing.ExtraScaling, (1 / 2^8), "Extra scale factor scaling should match UART expectation.");
            testCase.verifyEqual(idpuAnalysis.ScienceProcessing.ExtraScaling, (1 / 2^8) * (15/16)^2, ...
                "Extra scale factor scaling should match iDPU expectation.");

            testCase.verifyThat(matlab.unittest.constraints.EveryElementOf(idpuAnalysis.Results.Science.XYZ ./ uartAnalysis.Results.Science.XYZ), ...
                matlab.unittest.constraints.IsEqualTo((15/16)^2, Within = matlab.unittest.constraints.AbsoluteTolerance(1e-7)), ...
                "Ratio of analyzed science should match expectation.");
        end
    end
end
