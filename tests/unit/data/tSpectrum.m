classdef tSpectrum < matlab.unittest.TestCase
% TSPECTRUM Unit tests for "mag.Spectrum" class.

    properties (TestParameter)
        PropertyName = {"Time", "Frequency", "X", "Y", "Z"}
    end

    methods (Test)

        % Test that independent variable of the spectrum can be accessed.
        function independentVariable(testCase)

            % Set up.
            [spectrum, rawData] = testCase.createTestData();

            % Exercise.
            actualData = spectrum.IndependentVariable;

            % Verify.
            testCase.verifyEqual(actualData, meshgrid(rawData.Time, rawData.Frequency), "Independent property value should be as expected.");
        end

        % Test that dependent variables of the spectrum can be accessed.
        function dependentVariables(testCase)

            % Set up.
            [spectrum, rawData] = testCase.createTestData();

            % Exercise.
            actualData = spectrum.DependentVariables;

            % Verify.
            testCase.verifyEqual(actualData, cat(3, rawData.X, rawData.Y, rawData.Z), "Dependent property value should be as expected.");
        end

        % Test that dependent properties of the spectrum can be accessed.
        function dependentProperties(testCase, PropertyName)

            % Set up.
            [spectrum, rawData] = testCase.createTestData();

            % Exercise.
            actualData = spectrum.(PropertyName);

            % Verify.
            testCase.verifyEqual(actualData, rawData.(PropertyName), ...
                compose("Retireved property ""%s"" value should be as expected.", PropertyName));
        end
    end

    methods (Static, Access = private)

        function [spectrum, rawData] = createTestData()

            rawData = struct(Time = mag.test.DataTestUtilities.Time', Frequency = (0.1:0.1:1)', ...
                X = ones(10, 10), Y = 2 * ones(10, 10), Z = 3 * ones(10, 10));

            spectrum = mag.Spectrum(rawData.Time, rawData.Frequency, rawData.X, rawData.Y, rawData.Z);
        end
    end
end
