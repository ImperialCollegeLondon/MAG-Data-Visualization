function dateTime = combineDateAndTime(date, time, options)
% COMBINEDATEANDTIME Combine a datetime and an optional time string as a
% datetime.

    arguments (Input)
        date (1, 1) datetime
        time string {mustBeScalarOrEmpty} = string.empty()
        options.TimeZone string {mustBeScalarOrEmpty} = mag.time.Constant.TimeZone
    end

    arguments (Output)
        dateTime (1, 1) datetime
    end

    dateTime = date;

    if ~isempty(time) && (strlength(time) > 0)
        dateTime = dateTime + mag.time.decodeTime(time);
    end

    dateTime.Format = mag.time.Constant.Format;

    if ~isempty(options.TimeZone)
        dateTime.TimeZone = options.TimeZone;
    end
end
