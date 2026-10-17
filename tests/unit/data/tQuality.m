classdef (TestTags = ["Unit", "Parallel"]) tQuality < matlab.unittest.TestCase
% TQUALITY Unit tests for "mag.meta.Quality" enumeration.

    methods (Test)

        % Test that "isPlottable" method returns the correct value.
        function isPlottable(testCase)

            % Set up.
            qualityFlags = testCase.createTestValues();

            expectedValues = [true, false, true, true, true, false];

            % Exercise.
            actualValues = isPlottable(qualityFlags);

            % Verify.
            testCase.verifyEqual(actualValues, expectedValues, "Plottable values should match expectation.");
        end

        % Test that "isScience" method returns the correct value.
        function isScience(testCase)

            % Set up.
            qualityFlags = testCase.createTestValues();

            expectedValues = [false, false, true, false, true, false];

            % Exercise.
            actualValues = isScience(qualityFlags);

            % Verify.
            testCase.verifyEqual(actualValues, expectedValues, "Science values should match expectation.");
        end
    end

    methods (Static, Access = private)

        function qualityFlags = createTestValues()
            qualityFlags = [mag.meta.Quality.Artificial, mag.meta.Quality.Bad, mag.meta.Quality.Regular, mag.meta.Quality.Artificial, mag.meta.Quality.Regular, mag.meta.Quality.Bad];
        end
    end
end
