function time = decodeTime(time)
% DECODETIME Decode a time string as a duration.

    arguments (Input)
        time string {mustBeScalarOrEmpty}
    end

    arguments (Output)
        time duration {mustBeScalarOrEmpty}
    end

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

    error("Unable to parse time '%s' using the formats %s.", time, join(compose("'%s'", formats), ", "));
end
