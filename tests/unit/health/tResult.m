classdef tResult < matlab.unittest.TestCase
% TRESULT Unit tests for "mag.health.Result" class.

    methods (Test)

        function print(testCase)

            % Set up.
            results = [mag.health.Result(Name = "Test 1", Status = "Pass", Description = "My test 1."), ...
                mag.health.Result(Name = "Test 2", Status = "Fail", Description = "My test 2."), ...
                mag.health.Result(Name = "Test 3", Status = "Borderline", Description = "My test 3."), ...
                mag.health.Result(Name = "Test 4", Status = "Incomplete", Description = "My test 4.")]; %#ok<NASGU>

            expectedOutput = "Health check results:" + newline() + ...
                "    Test 1: My test 1." + newline() + ...
                "    Test 2: My test 2." + newline() + ...
                "    Test 3: [\bMy test 3.]\b" + newline() + ...
                "    Test 4: My test 4." + newline(); %#ok<NASGU>
            expectedOutput = evalc("fprintf(expectedOutput)");

            % Exercise.
            output = eraseTags(evalc("results.print()"));

            % Verify.
            testCase.verifyEqual(output, expectedOutput, "Printed output should match expectation.");
        end
    end
end
