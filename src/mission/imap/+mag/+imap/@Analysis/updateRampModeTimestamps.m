function events = updateRampModeTimestamps(events, data)

    % Improve ramp mode estimate.
    idxRamp = mag.imap.Analysis.findRampEvents(events);
    rampEvents = events(idxRamp, :);

    if isempty(rampEvents)
        return;
    end

    % Correct estimate based on science data.
    data = data(timerange(rampEvents.Time(1) - minutes(5), rampEvents.Time(end) + minutes(5), "closed"), :);
    time = data.Properties.RowTimes;

    matches = double.empty(2, 0);
    times = mag.time.emptyTime(2, 0);

    for v = ["x", "y", "z"]

        dv = diff(data.(v));
        m = strfind(dv', mag.process.Ramp.Pattern);

        if ~isempty(m)

            matches(:, end + 1) = [m(1); m(end)]; %#ok<AGROW>
            times(:, end + 1) = time(matches(:, end)); %#ok<AGROW>
        end
    end

    if isempty(times)
        return;
    elseif numel(unique(times)) > 2

        warning("mag:imap:InconsistentRampMode", "Inconsistent ramp mode. Selecting earliest and latest timestamps as beginning and end.");

        idxStart = min(matches(1, :));
        idxEnd = max(matches(end, :));
    else

        idxStart = matches(1);
        idxEnd = matches(end);
    end

    events.Time(idxRamp(1)) = time(idxStart);

    if ~isscalar(idxRamp)
        events.Time(idxRamp(end)) = time(min(idxEnd + numel(mag.process.Ramp.Pattern) + 1, height(data)));
    end
end
