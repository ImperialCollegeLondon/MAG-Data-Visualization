classdef (TestTags = ["Unit", "Parallel"]) tEventFilter < matlab.unittest.TestCase
% TEVENTFILTER Unit tests for "mag.process.EventFilter" class.

    methods (Test)

        % Test that alias is defined.
        function alias(testCase)
            testCase.verifyClass(mag.process.Filter(), "mag.process.EventFilter", "Alias ""mag.process.Filter"" should exist.");
        end

        % Test that filtering a range change close to the end of the data
        % marks available vectors as bad, without adding rows.
        function rangeChangeAtEndOfData(testCase)

            % Set up.
            time = datetime(2025, 1, 1, TimeZone = "UTC") + seconds((0:19)');
            data = timetable(time, ones(20, 1), repmat(mag.meta.Quality.Regular, 20, 1), VariableNames = ["x", "quality"]);

            events = timetable([1; 2], [2; 2], ["First"; "Second"], RowTimes = time([1, 19]), VariableNames = ["Range", "DataFrequency", "Label"]);
            data.Properties.Events = eventtable(events, EventLabelsVariable = "Label");

            % Exercise.
            filteredData = mag.process.EventFilter(OnRangeChange = [-1, 5]).apply(data, []);

            % Verify.
            testCase.assertEqual(height(filteredData), height(data), "Number of rows should not change.");

            testCase.verifyEqual(filteredData.quality(1:17), repmat(mag.meta.Quality.Regular, 17, 1), "Vectors before event should not change.");
            testCase.verifyEqual(filteredData.quality(18:20), repmat(mag.meta.Quality.Bad, 3, 1), "Vectors around event should be bad.");
        end
    end
end
