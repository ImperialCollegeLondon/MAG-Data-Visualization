classdef tImport < MAGIOTestCase & matlab.mock.TestCase
% TIMPORT Unit tests for "mag.io.import" function.

    methods (Test)

        % Test that when import files are empty, so is the output.
        function import_empty(testCase)

            % Set up.
            format = testCase.createMock(?mag.io.in.Format, Strict = true);

            % Exercise.
            data = mag.io.import(FileNames = string.empty(), Format = format);

            % Verify.
            testCase.verifyEmpty(data, "Import output should be empty.");
            testCase.verifyClass(data, "mag.TimeSeries", "Import output should be a ""mag.TimeSeries"".");
        end

        % Test that when importing science files of different sensors, they
        % are returned separately.
        function import_science_separate(testCase)

            % Set up.
            [format, formatBehavior, fileNames, data1, data2] = testCase.createScienceFormat();

            [step, stepBehavior] = testCase.createMock(?mag.process.Step, Strict = true);
            testCase.assignOutputsWhen(stepBehavior.apply(data1.Data, data1.Metadata), data1.Data);
            testCase.assignOutputsWhen(stepBehavior.apply(data2.Data, data2.Metadata), data2.Data);

            % Exercise.
            data = mag.io.import(FileNames = fileNames, Format = format, ProcessingSteps = step);

            % Verify.
            testCase.verifyClass(data, "mag.Science", "Import output should be a ""mag.Science"".");
            testCase.verifyNumElements(data, 2, "Science data should be separated by sensor.");

            testCase.verifyThat(withAnyInputs(formatBehavior.load), matlab.mock.constraints.WasCalled(WithCount = 2));
            testCase.verifyThat(withAnyInputs(formatBehavior.process), matlab.mock.constraints.WasCalled(WithCount = 2));

            testCase.verifyThat(withAnyInputs(stepBehavior.apply), matlab.mock.constraints.WasCalled(WithCount = 2));
        end

        % Test that when importing science files of same sensor, they are
        % all combined.
        function import_science_combined(testCase)

            % Set up.
            [format, formatBehavior, fileNames, data1, data2] = testCase.createScienceFormat(SecondarySensor = "FOB");

            [step, stepBehavior] = testCase.createMock(?mag.process.Step, Strict = true);
            testCase.assignOutputsWhen(stepBehavior.apply(data1.Data, data1.Metadata), data1.Data);
            testCase.assignOutputsWhen(stepBehavior.apply(data2.Data, data2.Metadata), data2.Data);

            % Exercise.
            data = mag.io.import(FileNames = fileNames, Format = format, ProcessingSteps = step);

            % Verify.
            testCase.verifyClass(data, "mag.Science", "Import output should be a ""mag.Science"".");
            testCase.verifyNumElements(data, 1, "Science data should be combined into one output.");

            testCase.verifyThat(withAnyInputs(formatBehavior.load), matlab.mock.constraints.WasCalled(WithCount = 2));
            testCase.verifyThat(withAnyInputs(formatBehavior.process), matlab.mock.constraints.WasCalled(WithCount = 2));

            testCase.verifyThat(withAnyInputs(stepBehavior.apply), matlab.mock.constraints.WasCalled(WithCount = 2));
        end

        % Test that when importing HK files of different types, they are
        % returned separately.
        function import_hk_separate(testCase)

            % Set up.
            [format, formatBehavior, fileNames, data1, data2] = testCase.createHKFormat();

            [step, stepBehavior] = testCase.createMock(?mag.process.Step, Strict = true);
            testCase.assignOutputsWhen(stepBehavior.apply(data1.Data, data1.Metadata), data1.Data);
            testCase.assignOutputsWhen(stepBehavior.apply(data2.Data, data2.Metadata), data2.Data);

            % Exercise.
            data = mag.io.import(FileNames = fileNames, Format = format, ProcessingSteps = step);

            % Verify.
            testCase.verifyClass(data, "mag.HK", "Import output should be a ""mag.HK"".");
            testCase.verifyNumElements(data, 2, "HK data should be separated by sensor.");

            testCase.verifyThat(withAnyInputs(formatBehavior.load), matlab.mock.constraints.WasCalled(WithCount = 2));
            testCase.verifyThat(withAnyInputs(formatBehavior.process), matlab.mock.constraints.WasCalled(WithCount = 2));

            testCase.verifyThat(withAnyInputs(stepBehavior.apply), matlab.mock.constraints.WasCalled(WithCount = 2));
        end

        % Test that when importing HK files of same type, they are all
        % combined.
        function import_hk_combined(testCase)

            % Set up.
            [format, formatBehavior, fileNames, data1, data2] = testCase.createHKFormat(SecondType = mag.meta.HKType.Power);

            [step, stepBehavior] = testCase.createMock(?mag.process.Step, Strict = true);
            testCase.assignOutputsWhen(stepBehavior.apply(data1.Data, data1.Metadata), data1.Data);
            testCase.assignOutputsWhen(stepBehavior.apply(data2.Data, data2.Metadata), data2.Data);

            % Exercise.
            data = mag.io.import(FileNames = fileNames, Format = format, ProcessingSteps = step);

            % Verify.
            testCase.verifyClass(data, "mag.imap.hk.Power", "Import output should be a ""mag.HK"".");
            testCase.verifyNumElements(data, 1, "HK data should be combined into one output.");

            testCase.verifyThat(withAnyInputs(formatBehavior.load), matlab.mock.constraints.WasCalled(WithCount = 2));
            testCase.verifyThat(withAnyInputs(formatBehavior.process), matlab.mock.constraints.WasCalled(WithCount = 2));

            testCase.verifyThat(withAnyInputs(stepBehavior.apply), matlab.mock.constraints.WasCalled(WithCount = 2));
        end
    end

    methods (Access = private)

        function [format, formatBehavior, fileNames, data1, data2] = createScienceFormat(testCase, options)

            arguments
                testCase (1, 1) tImport
                options.PrimarySensor (1, 1) mag.meta.Sensor = mag.meta.Sensor.FOB
                options.SecondarySensor (1, 1) mag.meta.Sensor = mag.meta.Sensor.FIB
            end

            fileNames = [fullfile(testCase.TestDataLocation, "MAGScience-normal-(2,2)-8s-20240410-15h26.csv"), ...
                fullfile(testCase.TestDataLocation, "burst_data20240410-15h25.csv")];

            rawData1 = table(1, 2, 3);
            details1 = "details1";
            data1 = mag.Science(timetable.empty(), mag.meta.Science(Sensor = options.PrimarySensor));

            rawData2 = table(4, 5, 6);
            details2 = "details2";
            data2 = mag.Science(timetable.empty(), mag.meta.Science(Sensor = options.SecondarySensor));

            [format, formatBehavior] = testCase.createMock(?mag.io.in.Format, Strict = true);

            testCase.assignOutputsWhen(formatBehavior.load(fileNames(1)), rawData1, details1);
            testCase.assignOutputsWhen(formatBehavior.load(fileNames(2)), rawData2, details2);

            testCase.assignOutputsWhen(formatBehavior.process(rawData1, details1), data1);
            testCase.assignOutputsWhen(formatBehavior.process(rawData2, details2), data2);
        end

        function [format, formatBehavior, fileNames, data1, data2] = createHKFormat(testCase, options)

            arguments
                testCase (1, 1) tImport
                options.FirstType (1, 1) mag.meta.HKType = mag.meta.HKType.Power
                options.SecondType (1, 1) mag.meta.HKType = mag.meta.HKType.Processor
            end

            fileNames = [fullfile(testCase.TestDataLocation, "MAGScience-normal-(2,2)-8s-20240410-15h26.csv"), ...
                fullfile(testCase.TestDataLocation, "burst_data20240410-15h25.csv")];

            rawData1 = table(1, 2, 3);
            details1 = "details1";
            data1 = mag.imap.hk.Power(timetable.empty(), mag.meta.HK(Type = options.FirstType));

            rawData2 = table(4, 5, 6);
            details2 = "details2";
            data2 = mag.imap.hk.Processor(timetable.empty(), mag.meta.HK(Type = options.SecondType));

            [format, formatBehavior] = testCase.createMock(?mag.io.in.Format, Strict = true);

            testCase.assignOutputsWhen(formatBehavior.load(fileNames(1)), rawData1, details1);
            testCase.assignOutputsWhen(formatBehavior.load(fileNames(2)), rawData2, details2);

            testCase.assignOutputsWhen(formatBehavior.process(rawData1, details1), data1);
            testCase.assignOutputsWhen(formatBehavior.process(rawData2, details2), data2);
        end
    end
end
