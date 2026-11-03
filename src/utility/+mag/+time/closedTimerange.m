function period = closedTimerange(startTime, endTime)
% CLOSEDTIMERANGE Closed time range between start and end times. A missing
% (NaT) start or end time leaves that side of the range unbounded.

    arguments (Input)
        startTime (1, 1) datetime
        endTime (1, 1) datetime
    end

    arguments (Output)
        period (1, 1) timerange
    end

    if ismissing(startTime)
        startTime = datetime("-Inf", TimeZone = mag.time.Constant.TimeZone);
    end

    if ismissing(endTime)
        endTime = datetime("Inf", TimeZone = mag.time.Constant.TimeZone);
    end

    period = timerange(startTime, endTime, "closed");
end
