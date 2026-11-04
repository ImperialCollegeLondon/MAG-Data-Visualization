function events = findModeChanges(data, events, name)
% FINDMODECHANGES Improve estimate of mode change times. If no events were
% logged, detect mode changes from timestamp cadence instead.

    arguments (Input)
        data timetable
        events timetable
        name (1, 1) string
    end

    arguments (Output)
        events timetable
    end

    data = sortrows(data);
    time = data.(data.Properties.DimensionNames{1});

    if isempty(events)
        events = detectModeChanges(data, time, events, name);
    else
        events = refineModeChanges(data, time, events);
    end
end

function events = detectModeChanges(data, time, events, name)
% DETECTMODECHANGES Find mode changes by looking at changes in timestamp
% cadence.

    % Find changes in timestamp cadence.
    t = time;
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

        modeTime = time(idxChange(i):(idxChange(i + 1) - 1));
        f = round(1 / seconds(mode(diff(modeTime))));

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
        e = table2timetable(e, RowTimes = modeTime(1));

        events = [events; eventtable(e, EventLabelsVariable = "Label")]; %#ok<AGROW>
    end

    % Remove duplicate events.
    events(find(diff(events.DataFrequency) == 0) + 1, :) = [];
end

function events = refineModeChanges(data, time, events)
% REFINEMODECHANGES Move logged mode changes to the change in timestamp
% cadence closest to them.

    searchWindow = seconds(30);

    % Update timestamps for mode changes.
    idxMode = find([true; diff(events.DataFrequency) ~= 0] & ~ismissing(events.DataFrequency) & ~ismissing(events.Duration));

    for i = 1:numel(idxMode)

        e = idxMode(i);

        if i == 1

            events.Time(e) = time(1);
            continue;
        end

        % Find window around event and compute actual timestamp difference.
        t = events.Time(e);

        eventWindow = data(withtol(t, searchWindow), :);
        windowTime = eventWindow.Properties.RowTimes;

        % Remove artificial timestamps, and data belonging to the previous
        % event (whose estimate was already improved).
        windowTime = windowTime(eventWindow.quality.isScience() & ~(windowTime < events.Time(idxMode(i - 1))));

        if isempty(windowTime)
            continue;
        end

        % Find time differences and filter out ones that are not
        % conventional.
        dt = seconds(diff(windowTime));

        dt(~ismembertol(dt, [0, 1 ./ 2.^(0:7)], 1e-3)) = NaN;
        dt = fillmissing(dt, "previous", EndValues = "nearest");

        ddt = diff(dt);

        if all(ddt == 0)
            events.Time(e) = windowTime(1);
        elseif all(abs(ddt) < 1e-3)

            if seconds(t - windowTime(1)) < 1.5
                events.Time(e) = windowTime(1);
            else

                [~, idxMin] = min(abs(t - windowTime));
                events.Time(e) = windowTime(idxMin);
            end
        else

            [~, idxChange] = max(ddt, [], ComparisonMethod = "abs");
            events.Time(e) = windowTime(idxChange + 1);
        end
    end
end
