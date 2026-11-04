classdef (Abstract, HandleCompatible) Signal
% SIGNAL Interface adding support for common signal operations.

    methods (Abstract)

        % RESAMPLE Resample data to the specified frequency.
        resample(this, targetFrequency)

        % DOWNSAMPLE Downsample data to the specified frequency.
        downsample(this, targetFrequency)
    end

    methods (Hidden, Sealed, Static)

        function mustBeConstantRate(value)
        % MUSTBECONSTANTRATE Validate that input value has constant rate.

            value(ismissing(value)) = [];

            if ~all(ismembertol(value, mode(value)))
                throwAsCaller(MException("mag:signal:NonConstantRate", "Data rate must be constant."));
            end
        end
    end
end
