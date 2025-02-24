classdef tCrop < MAGAnalysisTestCase
% TCROP Unit tests for "mag.process.Crop" class.

    methods (Test)

        function crop(testCase)

            % Set up.
            data = testCase.createTestData();

            % Exercise.
            cropStep = mag.process.Crop(NumberOfVectors = 2);
            processedData = cropStep.apply(data);

            % Verify.
            testCase.verifySize(processedData, [1, 5], "Data should be cropped in expected way.");
            testCase.verifyEqual(processedData(1, :), data(3, :), "Data should be cropped in expected way.");
        end
    end
end
