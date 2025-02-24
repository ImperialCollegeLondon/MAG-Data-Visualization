classdef tMissing < MAGAnalysisTestCase
% TMISSIMG Unit tests for "mag.process.Missing" class.

    methods (Test)

        function removeInterestingRowsWithNaNs(testCase)

            % Set up.
            a = [1; 2; 3];
            b = [4; NaN; 5];
            c = [6; NaN; 7];

            dataWithNaN = table(a, b, c, VariableNames = ["A", "B", "C"]);

            missingStep = mag.process.Missing(Variables = ["B", "C"]);

            % Exercise.
            dataWithoutNaN = missingStep.apply(dataWithNaN);

            % Verify.
            testCase.verifyEqual(dataWithoutNaN, dataWithNaN([1, 3], :), ...
                "Converted time should match expectation.");
        end

        function onlyRemoveRowsWithAllNaNs(testCase)

            % Set up.
            a = [1; 2; 3];
            b = [4; 0; 5];
            c = [6; NaN; 7];

            dataWithNaN = table(a, b, c, VariableNames = ["A", "B", "C"]);

            missingStep = mag.process.Missing(Variables = ["B", "C"]);

            % Exercise.
            dataWithoutNaN = missingStep.apply(dataWithNaN);

            % Verify.
            testCase.verifyEqual(dataWithoutNaN, dataWithNaN, ...
                "Converted time should match expectation.");
        end

        function ignoreNaNsInOtherRows(testCase)

            % Set up.
            a = [1; NaN; 3];
            b = [4; 0; 5];
            c = [6; 0; 7];

            dataWithNaN = table(a, b, c, VariableNames = ["A", "B", "C"]);

            missingStep = mag.process.Missing(Variables = ["B", "C"]);

            % Exercise.
            dataWithoutNaN = missingStep.apply(dataWithNaN);

            % Verify.
            testCase.verifyEqual(dataWithoutNaN, dataWithNaN, ...
                "Converted time should match expectation.");
        end
    end
end
