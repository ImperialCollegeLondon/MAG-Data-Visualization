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
            testCase.verifyEqual(idpuAnalysis.ScienceProcessing.ExtraScaling, 1, ...
                "Extra scale factor scaling should match iDPU expectation.", RelTol = 1e-6);

        end

        function helioSwarmScaleFactors(testCase)

            expectedScaleFactors = [0.007848358, 0.000253372, 6.4682E-05, 1.57585E-05; ...
                                    0.007700729, 0.000248428, 6.3446E-05, 1.54839E-05; ...
                                    0.007700729, 0.000248428, 6.3446E-05, 1.54839E-05];

            testCase.verifyEqual(mag.hs.Analysis.getScaleFactors(), expectedScaleFactors, ...
                "HelioSwarm scale factor matrix should match expectation.", RelTol = 1e-6);
        end

        function helioSwarmCompleteScaleFactors(testCase)

            expectedCompleteScaleFactors = [0.007848358, 0.000253372, 6.4682E-05, 1.57585E-05; ...
                                            0.007700729, 0.000248428, 6.3446E-05, 1.54839E-05; ...
                                            0.007700729, 0.000248428, 6.3446E-05, 1.54839E-05];

            testCase.verifyEqual(mag.hs.Analysis.getCompleteScaleFactors(), expectedCompleteScaleFactors, ...
                "Complete scale factor matrix should match expectation for iDPU.", RelTol = 1e-6);
        end
    end
end
