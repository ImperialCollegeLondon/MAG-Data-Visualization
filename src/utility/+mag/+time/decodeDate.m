function date = decodeDate(date, options)
% DECODEDATE Decode a date string as a duration.

    arguments (Input)
        date string {mustBeScalarOrEmpty}
        options.ExtraFormats (1, :) string = string.empty()
        options.TimeZone (1, 1) string = mag.time.Constant.TimeZone
        options.DisplayFormat (1, 1) string = mag.time.Constant.Format
    end

    arguments (Output)
        date datetime {mustBeScalarOrEmpty}
    end

    formats = ["dd-MMM-yyyy", "dd-MM-yyyy", "yyyy-MMM-dd", "yyyy-MM-dd"];
    formats = horzcat(formats, replace(formats, "-", "/"));
    formats = horzcat(formats, replace(formats, "-", " "));

    if ~isempty(options.ExtraFormats)
        formats = [formats, options.ExtraFormats];
    end

    conversion = @(f) datetime(date, InputFormat = f);

    for f = formats

        try

            date = conversion(f);

            date.TimeZone = options.TimeZone;
            date.Format = options.DisplayFormat;
            return;
        catch exception

            if ~ismember(exception.identifier, ["MATLAB:datetime:ParseErr", "MATLAB:datetime:ParseErrSuggestLocale"])
                exception.rethrow();
            end
        end
    end

    error("mag:time:ParseError", "Unable to parse date '%s' using the formats %s.", date, join(compose("'%s'", formats), ", "));
end
