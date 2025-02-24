classdef tDuplicates < MAGAnalysisTestCase
% TDUPLICATES Unit tests for "mag.process.Duplicates" class.

    methods (Test)

        function duplicates_none(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            duplicatesStep = mag.process.Duplicates();
            processedData = duplicatesStep.apply(data);

            % Verify.
            testCase.verifyEqual(processedData, data, "Data without duplicates should not be modified.");
        end

        function duplicates(testCase)

            % Set up.
            data = testCase.createTestData();

            modifiedData = [data; data(1, :)];
            modifiedData = [modifiedData; data(3, :)];

            modifiedData = sortrows(modifiedData);

            % Exercise.
            duplicatesStep = mag.process.Duplicates();
            processedData = testCase.verifyWarning(@() duplicatesStep.apply(modifiedData), "", ...
                "Warning should be issued when duplicates are present.");

            % Verify.
            testCase.verifyEqual(processedData, data, "Duplicates should be removed.");
            testCase.verifyEqual(duplicatesStep.DuplicateTimeStamps, 2, "Number of duplicates should be tracked.");
        end
    end
end
