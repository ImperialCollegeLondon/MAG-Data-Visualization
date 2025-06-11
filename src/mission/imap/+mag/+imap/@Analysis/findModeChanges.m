function events = findModeChanges(data, events, name)

    arguments (Input)
        data timetable
        events timetable
        name (1, 1) string
    end

    arguments (Output)
        events timetable
    end

    timeColumn = data.Properties.DimensionNames{1};

    % If there no events were detected, find mode changes by looking at
    % timestamp cadence.
    if isempty(events)

        data = sortrows(data);

        % Find changes in timestamp cadence.
        t = data.(timeColumn);
        dt = milliseconds(diff(t));

        idxRemove = find(ismissing(dt) | (dt < 1) | (dt > 1000)) + 1;
        idxRemove(idxRemove > height(data)) = height(data);

        t(idxRemove) = [];
        dt = milliseconds(diff(t));

        idxChange = findchangepts(dt, MinThreshold = 1);
        idxChange(diff(idxChange) == 1) = [];

        % Correct for data that was filtered out.
        for i = idxRemove'

            locUpdate = idxChange >= i;
            idxChange(locUpdate) = idxChange(locUpdate) + 1;
        end

        % Create event details.
        idxChange = [1; idxChange; height(data) + 1];

        for i = 1:(numel(idxChange) - 1)

            d = data(idxChange(i):(idxChange(i+1) - 1), :);
            f = round(1 / seconds(mode(diff(d.(timeColumn)))));

            if f < 8
                m = "Normal";
            else
                m = "Burst";
            end

            e = struct2table(struct(Mode = m, ...
                DataFrequency = f, ...
                PacketFrequency = NaN, ...
                Duration = 0, ...
                Range = NaN, ...
                Label = compose("%s %s (%d)", name, m, f), ...
                Reason = "Command"));
            t = table2timetable(e, RowTimes = d.(timeColumn)(1));

            events = [events; eventtable(t, EventLabelsVariable = "Label")]; %#ok<AGROW>
        end

        % Remove duplicate events.
        events(find(diff(events.DataFrequency) == 0) + 1, :) = [];
    else

        searchWindow = seconds(30);
        data = sortrows(data);

        % Update timestamps for mode changes.
        idxMode = find([true; diff(events.DataFrequency) ~= 0] & ~ismissing(events.DataFrequency) & ~ismissing(events.Duration));

        for i = 1:numel(idxMode)

            e = idxMode(i);

            if i == 1

                events.Time(e) = data.t(1);
                continue;
            end

            % Find window around event and compute actual timestamp
            % difference.
            t = events.Time(e);
            eventWindow = data(withtol(t, searchWindow), :);

            % Remove artificial timestamps.
            eventWindow = eventWindow(eventWindow.quality.isScience(), :);

            % Remove data belonging to the previous event (whose estimate
            % was already improved).
            eventWindow(eventWindow.t < events.Time(idxMode(i - 1)), :) = [];

            if isempty(eventWindow)
                continue;
            end

            % Find time differences and filter out ones that are not
            % conventional.
            dt = seconds(diff(eventWindow.(timeColumn)));

            idxOutlier = find(~ismembertol(dt, [0, 1 ./ 2.^(0:7)], 1e-3));
            dt(idxOutlier) = dt(idxOutlier - 1);

            ddt = diff(dt);

            if all(ddt == 0)
                events.Time(e) = eventWindow.t(1);
            elseif all(ddt < 1e-3)

                if seconds(t - eventWindow.t(1)) < 1.5
                    events.Time(e) = eventWindow.t(1);
                else

                    [~, idxMin] = min(abs(t - eventWindow.(timeColumn)));
                    events.Time(e) = eventWindow.(timeColumn)(idxMin);
                end
            else

                [~, idxChange] = max(ddt, [], ComparisonMethod = "abs");
                events.Time(e) = eventWindow.(timeColumn)(idxChange + 1);
            end
        end
    end
end
