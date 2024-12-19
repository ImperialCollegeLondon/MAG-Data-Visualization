function time = removeLeapSeconds(time, options)

    arguments (Input)
        time datetime {mustBeVector, mustBeUTCLeapSeconds}
        options.ReferenceEpoch (1, 1) datetime = datetime(2010, 1, 1)
    end

    arguments (Output)
        time datetime {mustBeVector}
    end

    ls = leapseconds();

    % Find leap seconds from reference epoch.
    ls.Adjustment = [ls.CumulativeAdjustment(1); diff(ls.CumulativeAdjustment)];

    ls = ls(ls.Date >= options.ReferenceEpoch, :);

    ls.Date.TimeZone = "UTC";

    % Remove leap seconds.
    time.TimeZone = "UTC";

    for i = 1:height(ls)
        time(time > ls.Date(i)) = time(time > ls.Date(i)) + ls{i, "Adjustment"};
    end
end

function mustBeUTCLeapSeconds(time)

    if ~isequal(time.TimeZone, "UTCLeapSeconds")
        error("""datetime"" must be in ""UTCLeapSeconds"" time zone.");
    end
end
