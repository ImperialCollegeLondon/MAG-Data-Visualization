function dateTime = combineDateAndTime(date, time)
% COMBINEDATEANDTIME Combine a datetime and an optional time string as a
% datetime.

    arguments (Input)
        date (1, 1) datetime
        time string {mustBeScalarOrEmpty}
    end

    arguments (Output)
        dateTime (1, 1) datetime
    end

    dateTime = date;

    if ~isempty(time)
        dateTime = dateTime + decodeTime(time);
    end

    dateTime.Format = mag.time.Constant.Format;
    dateTime.TimeZone = mag.time.Constant.TimeZone;
end

function time = decodeTime(time)

    formats = ["hh:mm", "hh:mm:ss", "hh:mm:ss.SSS"];
    conversion = @(f) duration(time, InputFormat = f);

    for f = formats

        try

            time = conversion(f);
            return;
        catch exception

            if ~isequal(exception.identifier, "MATLAB:duration:DataMismatchedFormat")
                exception.rethrow();
            end
        end
    end

    error("Unable to parse '%s' using the formats %s.", time, join(compose("'%s'", formats), ", "));
end
