function time = decodeTime(time, options)
% DECODETIME Decode a time string as a duration.

    arguments (Input)
        time string {mustBeScalarOrEmpty}
        options.ExtraFormats (1, :) string = string.empty()
    end

    arguments (Output)
        time duration {mustBeScalarOrEmpty}
    end

    formats = ["hh:mm", "hh:mm:ss", "hh:mm:ss.SSS"];

    if ~isempty(options.ExtraFormats)
        formats = [formats, options.ExtraFormats];
    end

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

    error("mag:time:ParseError", "Unable to parse time '%s' using the formats %s.", time, join(compose("'%s'", formats), ", "));
end
