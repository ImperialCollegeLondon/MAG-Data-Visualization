classdef tConvert < MAGAnalysisTestCase
% TCONVERT Unit tests for "mag.process.Convert" class.

    methods (Test)

        function convertToDouble(testCase)

            % Set up.
            data = testCase.createSimpleTestData();

            % Exercise.
            convertStep = mag.process.Convert(DataType = "double", Variables = ["A", "C"]);
            processedData = convertStep.apply(data);

            % Verify.
            testCase.verifyClass(processedData.A, "double", "Data should be converted to expected type.");
            testCase.verifyClass(processedData.C, "double", "Data should be converted to expected type.");
        end

        function convert_empty(testCase)

            % Set up.
            data = table();

            % Exercise.
            convertStep = mag.process.Convert(DataType = "double", Variables = "A");
            processedData = convertStep.apply(data);

            % Verify.
            testCase.verifyEmpty(processedData, "Nothing should be done to empty table.");
        end
    end

    methods (Static, Access = private)

        function data = createSimpleTestData()

            a = uint32([1; 2; 3]);
            b = [4; NaN; 5];
            c = [true; false; true];

            data = table(a, b, c, VariableNames = ["A", "B", "C"]);
        end
    end
end
