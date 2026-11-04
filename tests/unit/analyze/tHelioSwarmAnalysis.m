classdef (TestTags = ["Unit", "Parallel"]) tHelioSwarmAnalysis < matlab.unittest.TestCase
% THELIOSWARMANALYSIS Unit tests for "mag.hs.Analysis" class.

    methods (Test)

        % Test that selecting iDPU input source changes scale factors.
        function iDPU_scaleFactors(testCase)

            % Set up.
            location = fullfile(fileparts(mfilename("fullpath")), "test_data");

            % Exercise.
            idpuAnalysis = mag.hs.Analysis.start(Location = location);

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

        % Test that detecting files does not decode binary files, which
        % would write new files.
        function detect_doesNotDecode(testCase)

            % Set up.
            location = testCase.createTemporaryFolder();
            writelines("", fullfile(location, "hs_20250101_000000.361_m128"));

            analysis = mag.hs.Analysis(Location = location, DecodeBinaryFiles = true);

            % Exercise and verify.
            testCase.verifyWarningFree(@() analysis.detect(), "Detection should not try to decode binary files.");
            testCase.verifyNumElements(dir(fullfile(location, "*.*")), 3, "Detection should not write files.");
        end

        % Test that CDF export is rejected, as it is not implemented.
        function export_cdfNotSupported(testCase)

            analysis = mag.hs.Analysis();

            testCase.verifyError(@() analysis.export("CDF", Location = pwd()), "MATLAB:validators:mustBeMember", ...
                "Error should be thrown for unsupported export format.");
        end
    end
end
