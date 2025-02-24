classdef tCompression < MAGAnalysisTestCase
% TCOMPRESSION Unit tests for "mag.process.Compression" class.

    methods (Test)

        % Test that compression width is used to determine correction
        % factor.
        function compressionWidth_variable(testCase)

            % Set up.
            compressedData = testCase.createCompressedTestData();

            expectedXYZ = [1, 1, 1; 1, 1, 1; 0.25, 0.25, 0.25; 1, 1, 1];

            % Exercise.
            compressionStep = mag.process.Compression(Variables = ["x", "y", "z"], ...
                CompressionVariable = "comprs", ...
                CompressionWidthVariable = "comprs_width");
            uncompessedData = compressionStep.apply(compressedData);

            % Verify.
            testCase.verifyEqual(uncompessedData{:, ["x", "y", "z"]}, expectedXYZ, ...
                "Uncompressed data should match expectation.");

            unchangedVariables = setdiff(compressedData.Properties.VariableNames, compressionStep.Variables);
            testCase.verifyEqual(uncompessedData(:, unchangedVariables), compressedData(:, unchangedVariables), ...
                "Compression unrelated variables should not be modified.");
        end

        % Test that correction factor can be overwritten as input.
        function compressionWidth_overwrite(testCase)

            % Set up.
            compressedData = testCase.createCompressedTestData();

            expectedXYZ = [ones(1, 3); 0.5 * ones(2, 3); ones(1, 3)];

            % Exercise.
            compressionStep = mag.process.Compression(Variables = ["x", "y", "z"], ...
                CompressionVariable = "comprs", ...
                CorrectionFactor = 2);
            uncompessedData = compressionStep.apply(compressedData);

            % Verify.
            testCase.verifyEqual(uncompessedData{:, ["x", "y", "z"]}, expectedXYZ, ...
                "Uncompressed data should match expectation.");

            unchangedVariables = setdiff(compressedData.Properties.VariableNames, compressionStep.Variables);
            testCase.verifyEqual(uncompessedData(:, unchangedVariables), compressedData(:, unchangedVariables), ...
                "Compression unrelated variables should not be modified.");
        end

        % Test that default behavior when no compression width variable
        % exists, is to not modify the data.
        function compressionWidth_default(testCase)

            % Set up.
            compressedData = testCase.createCompressedTestData();

            expectedXYZ = ones(4, 3);

            % Exercise.
            compressionStep = mag.process.Compression(Variables = ["x", "y", "z"], ...
                CompressionVariable = "comprs", ...
                CompressionWidthVariable = "nonexistent_variable");
            uncompessedData = compressionStep.apply(compressedData);

            % Verify.
            testCase.verifyEqual(uncompessedData{:, ["x", "y", "z"]}, expectedXYZ, ...
                "Uncompressed data should match expectation.");

            unchangedVariables = setdiff(compressedData.Properties.VariableNames, compressionStep.Variables);
            testCase.verifyEqual(uncompessedData(:, unchangedVariables), compressedData(:, unchangedVariables), ...
                "Compression unrelated variables should not be modified.");
        end
    end

    methods (Access = private)

        function compressedData = createCompressedTestData(testCase)

            compressedData = testCase.createTestData( ...
                Time = [datetime("yesterday"), datetime("today"), datetime("now"), datetime("tomorrow")], ...
                XYZ = ones(4, 3), ...
                Range = zeros(4, 1), ...
                Sequence = (1:4)');

            compressedData.comprs = [false; true; true; false];
            compressedData.comprs_width = [16; 16; 18; 0];
        end
    end
end
