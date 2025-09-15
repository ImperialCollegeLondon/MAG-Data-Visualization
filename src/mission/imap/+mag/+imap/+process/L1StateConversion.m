classdef L1StateConversion < mag.process.Step
% L1STATECONVERSION Convert from L1 states.

    methods

        function data = apply(this, data, ~)

            arguments
                this
                data tabular
                ~
            end

            % Convert logical states to boolean.
            data = convertvars(data, @matlab.internal.datatypes.isText, @this.convertStateToLogical);

            % Convert ranges.
            data = convertvars(data, @matlab.internal.datatypes.isText, @this.convertRangeToEnum);

            % Convert mode frequency and cadence.
            data = convertvars(data, @matlab.internal.datatypes.isText, @this.convertModeCadenceToDouble);
        end
    end

    methods (Static, Access = private)

        function convertedValue = convertStateToLogical(value)

            if any(value == "Saturated") || any(value == "NotSaturated")
                convertedValue = value == "Saturated";
            elseif any(value == "Enabled") || any(value == "Disabled")
                convertedValue = value == "Enabled";
            else
                convertedValue = value;
            end
        end

        function convertedValue = convertRangeToEnum(value)

            if any(contains(value, "range", IgnoreCase = true))
                convertedValue = mag.meta.Range(str2double(erase(value, lettersPattern())));
            else
                convertedValue = value;
            end
        end

        function convertedValue = convertModeCadenceToDouble(value)

            pattern = regexpPattern("(HZ_|SECS_)", IgnoreCase = true);

            if any(startsWith(value, pattern))
                convertedValue = str2double(erase(value, pattern()));
            else
                convertedValue = value;
            end
        end
    end
end
