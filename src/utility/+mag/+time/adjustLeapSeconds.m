function time = adjustLeapSeconds(time, options)

    arguments (Input)
        time datetime {mustBeVector, mustBeUTC}
        options.ReferenceEpoch (1, 1) datetime = datetime(2010, 1, 1)
    end

    arguments (Output)
        time datetime {mustBeVector}
    end

    ls = leapseconds();

    % Find leap seconds from reference epoch.
    ls.Adjustment = [ls.CumulativeAdjustment(1); diff(ls.CumulativeAdjustment)];

    ls = ls(ls.Date >= options.ReferenceEpoch, :);

    % Adjust for leap seconds.
    switch time.TimeZone
        case "UTC"

            sign = -1;
            time.TimeZone = "UTCLeapSeconds";
            ls.Date.TimeZone = "UTCLeapSeconds";
        case "UTCLeapSeconds"

            sign = +1;
            time.TimeZone = "UTC";
            ls.Date.TimeZone = "UTC";
        otherwise
            error("Unsupported time zone ""%s"".", time.TimeZone);
    end

    for i = 1:height(ls)
        time(time > ls.Date(i)) = time(time > ls.Date(i)) + (sign * ls{i, "Adjustment"});
    end
end

function mustBeUTC(time)

    if ~ismember(time.TimeZone, ["UTC", "UTCLeapSeconds"])
        error("""datetime"" must be in ""UTCLeapSeconds"" time zone.");
    end
end
