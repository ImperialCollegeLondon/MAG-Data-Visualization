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

        function helioSwarmScaleFactors(testCase)

            expectedScaleFactors = [2.286, 0.0738, 0.01884, 0.00459; ...
                                    2.243, 0.07236, 0.01848, 0.00451; ...
                                    2.243, 0.07236, 0.01848, 0.00451];

            testCase.verifyEqual(mag.hs.Analysis.getScaleFactors(), expectedScaleFactors, ...
                "HelioSwarm scale factor matrix should match expectation.");
        end

        function helioSwarmCompleteScaleFactors(testCase)

            expectedCompleteScaleFactors = ((1 / 2^8) * (15 / 16)^2) * [2.286, 0.0738, 0.01884, 0.00459; ...
                                                                         2.243, 0.07236, 0.01848, 0.00451; ...
                                                                         2.243, 0.07236, 0.01848, 0.00451];

            testCase.verifyEqual(mag.hs.Analysis.getCompleteScaleFactors(), expectedCompleteScaleFactors, ...
                "Complete scale factor matrix should match expectation for iDPU.");
        end
    end
end
