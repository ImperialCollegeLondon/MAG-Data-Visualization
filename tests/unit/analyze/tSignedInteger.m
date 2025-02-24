classdef tSignedInteger < MAGAnalysisTestCase
% TSIGNEDINTEGER Unit tests for "mag.process.SignedInteger" class.

    properties (TestParameter)
        UnsignedInteger = {double(0b1010010011100111s16), double(0b0100100110101010s16), [double(0b1010010011100111s16), double(0b0100110110001010s16); double(0b0100100110101010s16), double(0b1100101110100010s16)]}
        SignedInteger = {-23321, 18858, [-23321, 19850; 18858, -13406]}
    end

    methods (Test, ParameterCombination = "sequential")

        function convertToSignedInteger(testCase, UnsignedInteger, SignedInteger)

            % Set up.
            signedIntegerStep = mag.process.SignedInteger();

            % Exercise.
            convertedInteger = signedIntegerStep.convertToSignedInteger(UnsignedInteger);

            % Verify.
            testCase.verifyEqual(convertedInteger, SignedInteger, "Converted value should match expectation.");
        end
    end
end
