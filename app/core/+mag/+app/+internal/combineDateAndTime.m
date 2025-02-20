function dateTime = combineDateAndTime(date, time)
% COMBINEDATEANDTIME Combine a datetime and an optional time string as a
% datetime.

    arguments (Input)
        date (1, 1) datetime
        time string {mustBeScalarOrEmpty} = string.empty()
    end

    arguments (Output)
        dateTime (1, 1) datetime
    end

    dateTime = date;

    if ~isempty(time)
        dateTime = dateTime + mag.time.decodeTime(time);
    end

    dateTime.Format = mag.time.Constant.Format;
    dateTime.TimeZone = mag.time.Constant.TimeZone;
end
