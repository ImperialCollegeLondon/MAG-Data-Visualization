classdef tHK < matlab.unittest.TestCase
% THK Unit tests for "mag.HK" class.

    properties (TestParameter)
        HKTypes = {"SID15", "Processor", "Power", "Status"}
        Dispatch = {struct(Type = "SID15", Class = "mag.hk.SID15"), ...
            struct(Type = "PROCSTAT", Class = "mag.hk.Processor"), ...
            struct(Type = "PW", Class = "mag.hk.Power"), ...
            struct(Type = "STATUS", Class = "mag.hk.Status")}
    end

    methods (Test)

        % Test that "crop" method crops data based on a "timerange" object.
        function cropMethod_timerange(testCase)

            % Set up.
            hk = testCase.createTestData();

            expectedTimes = {hk(1).Time(3:end), hk(2).Time(2:end)};
            expectedData = {hk(1).DependentVariables(3:end, :), hk(2).DependentVariables(2:end, :)};

            timeFilter = timerange(hk(1).Time(2), hk(1).Time(end), "openleft");

            % Exercise and verify.
            testCase.cropAndVerify(hk, timeFilter, expectedTimes, expectedData);
        end

        % Test that "crop" method does not fail when no data is selected.
        function cropMethod_noSelection(testCase)

            % Set up.
            hk = testCase.createTestData();

            % Exercise.
            hk.crop(timerange(datetime("Inf", TimeZone = "local"), datetime("-Inf", TimeZone = "local")));

            % Verify.
            for i = 1:numel(hk)

                testCase.verifyEmpty(hk(i).IndependentVariable, "All data should be cropped out.");
                testCase.verifyEmpty(hk(i).DependentVariables, "All data should be cropped out.");

                testCase.verifyTrue(ismissing(hk(i).MetaData.Timestamp), "All data should be cropped out.");
            end
        end

        % Test that "resample" method can resample to a higher frequency.
        function resampleMethod_higherFrequency(testCase)

            % Set up.
            hk = testCase.createTestData();
            hk = hk(1);

            initialFrequency = 1 / seconds(mode(hk.dT));

            % Exercise.
            resampledData = hk.copy();
            resampledData.resample(2 * initialFrequency);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), (2 * height(hk.Time)) - 1, "Frequency should be halved.");
            testCase.verifyEqual(resampledData.Time, (hk.Time(1):seconds(30):hk.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(resampledData.DependentVariables), (2 * height(hk.DependentVariables)) - 1, "Frequency should be halved.");
        end

        % Test that "downsample" method can resample to a lower frequency.
        function downsampleMethod_lowerFrequency(testCase)

            % Set up.
            hk = testCase.createTestData();
            hk = hk(1);

            initialFrequency = 1 / seconds(mode(hk.dT));

            % Exercise.
            resampledData = hk.copy();
            resampledData.downsample(initialFrequency / 2);

            % Verify.
            testCase.assertEqual(height(resampledData.IndependentVariable), height(hk.Time) / 2, "Frequency should be halved.");
            testCase.verifyEqual(resampledData.Time, (hk.Time(1):minutes(2):hk.Time(end))', "Frequency should be halved.");

            testCase.assertEqual(height(resampledData.DependentVariables), height(hk.DependentVariables) / 2, "Frequency should be halved.");
        end

        % Test that "getHKType" returns empty on empty input.
        function getHKType_empty(testCase)

            % Set up.
            hk = mag.hk.Power.empty();

            % Exercise.
            selectedHK = hk.getHKType("PROCSTAT");

            % Verify.
            testCase.verifyEmpty(selectedHK, "Empty should be returned for empty input.");
        end

        % Test that "getHKType" method returns Power HK by default.
        function getHKType_default(testCase)

            % Set up.
            hk = testCase.createTestData();

            % Exercise.
            selectedHK = hk.getHKType();

            % Verify.
            testCase.verifyEmpty(selectedHK, "Empty should be returned when no such type exists.");
        end

        % Test that "getHKType" method selects the correct type.
        function getHKType(testCase)

            % Set up.
            hk = testCase.createTestData();

            % Exercise.
            selectedHK = hk.getHKType("PROCSTAT");

            % Verify.
            testCase.verifyClass(selectedHK, "mag.hk.Processor", "Correct type should be returned.");
        end

        % Test that all dependent properties of the HK types supported can
        % be accessed.
        function dependentProperties(~, HKTypes)

            % Set up.
            fileName = fullfile(fileparts(mfilename("fullpath")), "../../data", HKTypes + ".csv");

            hk = readtimetable(fileName);
            hk.Properties.DimensionNames{1} = 't';

            metaClass = meta.class.fromName("mag.hk." + HKTypes);
            properties = metaClass.PropertyList;

            % Exercise and verify.
            hk = mag.hk.(HKTypes)(hk, mag.meta.HK());

            for p = properties([properties.Dependent] & cellfun(@(x) isequal(x, "public"), {properties.GetAccess}))'
                hk.(p.Name);
            end
        end

        % Test that displaying a deleted handle does not error.
        function customDisplay_deleted(testCase)

            % Set up.
            hk = testCase.createTestData();
            hk = hk(1);

            delete(hk);

            % Exercise and verify.
            evalc("display(hk)");
        end

        % Test that displaying an empty array does not error.
        function customDisplay_empty(~)

            % Set up.
            hk = mag.hk.Power.empty(); %#ok<NASGU>

            % Exercise and verify.
            evalc("display(hk)");
        end

        % Test that displaying a single object displays the correct
        % information.
        function customDisplay_singleObject(testCase)

            % Set up.
            hk = testCase.createTestData(); %#ok<NASGU>

            % Exercise.
            output = evalc("display(hk(1))");

            % Verify.
            testCase.verifySubstring(eraseTags(output), "Status HK (STATUS)", "HK meta data should be included in display.");
        end

        % Test that displaying heterogeneous arrays does not error.
        function customDisplay_heterogeneous(testCase)

            % Set up.
            hk = testCase.createTestData(); %#ok<NASGU>

            % Exercise and verify.
            evalc("display(hk)");
        end

        % Test that HK data is dispatched to the correct class.
        function dispatchHKType(testCase, Dispatch)

            % Set up.
            tt = timetable.empty();
            metaData = mag.meta.HK(Type = Dispatch.Type);

            % Exercise.
            hk = mag.hk.dispatchHKType(tt, metaData);

            % Verify.
            testCase.verifyClass(hk, Dispatch.Class, "HK data should be dispateched to correct type.");
        end
    end

    methods (Access = private)

        function cropAndVerify(testCase, hk, timeFilter, expectedTimes, expectedData)

            % Exercise.
            hk.crop(timeFilter);

            % Verify.
            for i = 1:numel(hk)

                testCase.assertSize(hk(i).IndependentVariable, size(expectedTimes{i}), "Data should be cropped as expected.");
                testCase.verifyEqual(hk(i).Time, expectedTimes{i}, "Data should be cropped as expected.");

                testCase.assertSize(hk(i).DependentVariables, size(expectedData{i}), "Data should be cropped as expected.");
                testCase.verifyEqual(hk(i).DependentVariables, expectedData{i}, "Data should be cropped as expected.");

                testCase.verifyEqual(hk(i).MetaData.Timestamp, hk(i).Time(1), "Meta data timestamp should be updated.");
            end
        end
    end

    methods (Static, Access = private)

        function hk = createTestData()

            timestamps = datetime("now", TimeZone = "UTC") + minutes(1:10)';

            statusData = timetable(timestamps, ones(10, 1), zeros(10, 1), VariableNames = ["FOBSTAT", "FIBSTAT"]);
            procstatData = timetable(timestamps(1:2:end), (1:5)', (11:15)', VariableNames = ["OBNQ_NUM_MSG", "IBNQ_NUM_MSG"]);

            hk(1) = mag.hk.Status(statusData, mag.meta.HK(Type = "STATUS"));
            hk(2) = mag.hk.Processor(procstatData, mag.meta.HK(Type = "PROCSTAT"));
        end
    end
end
