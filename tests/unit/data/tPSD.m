classdef tPSD < matlab.unittest.TestCase
% TPSD Unit tests for "mag.PSD" class.

    properties (TestParameter)
        PropertyName = {struct(Public = "Frequency", Private = "f"), ...
            struct(Public = "X", Private = "x"), ...
            struct(Public = "Y", Private = "y"), ...
            struct(Public = "Z", Private = "z")}
    end

    methods (Test)

        % Test that independent variable of the PSD can be accessed.
        function independentVariable(testCase)

            % Set up.
            [psd, rawData] = testCase.createTestData();

            % Exercise.
            actualData = psd.IndependentVariable;

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, "f"}, "Independent property value should be as expected.");
        end

        % Test that dependent variables of the PSD can be accessed.
        function dependentVariables(testCase)

            % Set up.
            [psd, rawData] = testCase.createTestData();

            % Exercise.
            actualData = psd.DependentVariables;

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, ["x", "y", "z"]}, "Dependent property value should be as expected.");
        end

        % Test that dependent properties of the PSD can be accessed.
        function dependentProperties(testCase, PropertyName)

            % Set up.
            [psd, rawData] = testCase.createTestData();

            % Exercise.
            actualData = psd.(PropertyName.Public);

            % Verify.
            testCase.verifyEqual(actualData, rawData{:, PropertyName.Private}, "Retireved property value should be as expected.");
        end
    end

    methods (Static, Access = private)

        function [psd, rawData] = createTestData()

            rawData = table((1:10)', (1:10)', (11:20)', (21:30)', VariableNames = ["f", "x", "y", "z"]);
            psd = mag.PSD(rawData);
        end
    end
end
