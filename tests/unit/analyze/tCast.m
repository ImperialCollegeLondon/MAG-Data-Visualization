classdef tCast < MAGAnalysisTestCase
% TCAST Unit tests for "mag.process.Cast" class.

    methods (Test)

        function castIntegerToDouble(testCase)

            % Set up.
            data = testCase.createSimpleTestData();

            % Exercise.
            castStep = mag.process.Cast(DataType = "double", Variables = "A");
            processedData = castStep.apply(data);

            % Verify.
            testCase.verifyClass(processedData.A, "double", ...
                "Data should be cast to expected type.");
        end

        function castLogicalToInteger(testCase)

            % Set up.
            data = testCase.createSimpleTestData();

            % Exercise.
            castStep = mag.process.Cast(DataType = "int16", Variables = "C");
            processedData = castStep.apply(data);

            % Verify.
            testCase.verifyClass(processedData.C, "int16", ...
                "Data should be cast to expected type.");
        end

        function cast_empty(testCase)

            % Set up.
            data = table();

            % Exercise.
            castStep = mag.process.Cast(DataType = "double", Variables = "A");
            processedData = castStep.apply(data);

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
