function date = decodeDate(date)
% DECODEDATE Decode a date string as a duration.

    arguments (Input)
        date string {mustBeScalarOrEmpty}
    end

    arguments (Output)
        date datetime {mustBeScalarOrEmpty}
    end

    formats = ["dd/MM/yyyy", "dd-MMM-yyyy", "dd-MM-yyyy"];
    conversion = @(f) datetime(date, InputFormat = f);

    for f = formats

        try

            date = conversion(f);

            date.TimeZone = mag.time.Constant.TimeZone;
            date.Format = mag.time.Constant.Format;
            return;
        catch exception

            if ~ismember(exception.identifier, ["MATLAB:datetime:ParseErr", "MATLAB:datetime:ParseErrSuggestLocale"])
                exception.rethrow();
            end
        end
    end

    error("Unable to parse date '%s' using the formats %s.", date, join(compose("'%s'", formats), ", "));
end
