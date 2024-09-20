classdef tExport < MAGIOTestCase & matlab.mock.TestCase
% TEXPORT Unit tests for "mag.io.export" function.

    methods (Test)

        % Test that "export" function works as expected when no file name
        % is provided.
        function export_defaultFileName(testCase)

            % Set up.
            data = mag.imap.Instrument();
            location = testCase.WorkingDirectory.Folder;

            fileName = "myExportFileName";
            exportData = table.empty();

            [format, formatBehavior] = testCase.createMock(?mag.io.out.Format);
            testCase.assignOutputsWhen(formatBehavior.getExportFileName(data), fileName);
            testCase.assignOutputsWhen(formatBehavior.convertToExportFormat(data), exportData);

            % Exercise.
            mag.io.export(data, Location = location, Format = format);

            % Verify.
            testCase.verifyCalled(formatBehavior.convertToExportFormat(data), "Conversion method should be called.");
            testCase.verifyCalled(formatBehavior.write(fullfile(location, fileName), exportData), "Conversion method should be called.");
        end

        % Test that "export" function works as expected when file name is
        % provided.
        function export_specifiedFileName(testCase)

            % Set up.
            data = mag.imap.Instrument();
            location = testCase.WorkingDirectory.Folder;

            fileName = "myExportFileName";
            exportData = table.empty();

            [format, formatBehavior] = testCase.createMock(?mag.io.out.Format);
            testCase.assignOutputsWhen(formatBehavior.convertToExportFormat(data), exportData);

            % Exercise.
            mag.io.export(data, Location = location, FileName = fileName, Format = format);

            % Verify.
            testCase.verifyCalled(formatBehavior.convertToExportFormat(data), "Conversion method should be called.");
            testCase.verifyCalled(formatBehavior.write(fullfile(location, fileName), exportData), "Conversion method should be called.");
        end
    end
end
