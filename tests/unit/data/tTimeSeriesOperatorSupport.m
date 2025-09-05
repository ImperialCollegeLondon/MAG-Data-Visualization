classdef tTimeSeriesOperatorSupport < matlab.unittest.TestCase
% TTIMESERIESOPERATORSUPPORT Unit tests for
% "mag.mixin.TimeSeriesOperatorSupport" class.

    properties (TestParameter)
        Operation = {
            struct(Function = @plus, Result = tTimeSeriesOperatorSupport.getPlusResult()), ...
            struct(Function = @minus, Result = tTimeSeriesOperatorSupport.getMinusResult())}
    end

    methods (Test)

        % Test that supported operations yield the expected result.
        function test_supportedOperations(testCase, Operation)

            % Set up.
            [a, b] = testCase.createTestData();

            % Exercise.
            result = Operation.Function(a, b);

            % Verify.
            testCase.verifyEqual(result, Operation.Result, "Operation result should match expectation.");
        end

        % Test that operation with unsupported type falls back to built-in
        % command.
        function test_operationFallbackBuiltin(testCase)

            % Set up.
            a = TestTimeSeriesWithOperationSupport();

            % Exercise and verify.
            testCase.verifyError(@() a + 2, ?MException, ...
                "Operation must fall back to built-in command when unsupported.");
        end

        % Test that "join" can be called on two different instances of
        % mag.mixin.TimeSeriesOperatorSupport.
        function test_joinWithThat(testCase)

            % Set up.
            [a, b] = testCase.createTestData();
            a.Data.Time = a.Data.Time + hours(1);

            % Exercise.
            result = a.join(b);

            % Verify.
            testCase.verifyEqual(result.Data, [b.Data; a.Data], "Joined data should match the concatenated data.");
        end

        % Test that "join" can be called on an array instances of
        % mag.mixin.TimeSeriesOperatorSupport.
        function test_joinWithArrayThis(testCase)

            % Set up.
            [a, b] = testCase.createTestData();
            a.Data.Time = a.Data.Time + hours(1);

            c = [a, b];

            % Exercise.
            result = c.join();

            % Verify.
            testCase.verifyEqual(result.Data, [b.Data; a.Data], "Joined data should match the concatenated data.");
        end

        % Test that "join" throws an error when called with unsupported
        % datatypes.
        function test_joinUnsupportedType(testCase)

            % Set up.
            a = TestTimeSeriesWithOperationSupport();

            % Exercise and verify.
            testCase.verifyError(@() a.join("unsupportedType"), "mag:join:UnsupportedType", ...
                "Error should be thrown with unsupported type.");
        end
    end

    methods (Static, Access = private)

        function [a, b] = createTestData()

            a = TestTimeSeriesWithOperationSupport();
            b = TestTimeSeriesWithOperationSupport();

            a.Data = mag.test.DataTestUtilities.getScienceTimetable();
            b.Data = mag.test.DataTestUtilities.getScienceTimetable();
        end

        function result = getPlusResult()

            result = TestTimeSeriesWithOperationSupport();
            result.Data = mag.test.DataTestUtilities.getScienceTimetable();

            result.Data = convertvars(result.Data, regexpPattern(".*"), "double");
            result.Data{:, :} = result.Data{:, :} * 2;
        end

        function result = getMinusResult()

            result = TestTimeSeriesWithOperationSupport();
            result.Data = mag.test.DataTestUtilities.getScienceTimetable();

            result.Data = convertvars(result.Data, regexpPattern(".*"), "double");
            result.Data{:, :} = 0;
        end
    end
end
