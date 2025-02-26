classdef (Abstract) Data < matlab.mixin.Copyable & matlab.mixin.Heterogeneous & mag.mixin.SetGet & mag.mixin.Struct
% DATA Description of MAG telemetry data.
%
% Includes description of which sensor, mode and frequency was used, and
% when the measurement started.

    properties
        % DESCRIPTION Description of MAG data.
        Description string {mustBeScalarOrEmpty}
        % TIMESTAMP Timestamp of metadata.
        Timestamp (1, 1) datetime = NaT(TimeZone = mag.time.Constant.TimeZone)
    end

    methods

        function set.Timestamp(this, value)
            this.Timestamp = datetime(value, TimeZone = mag.time.Constant.TimeZone, Format = mag.time.Constant.Format);
        end
    end

    methods (Sealed)

        function value = getDisplay(this, property, alternative)
        % GETDISPLAY Get property value for display purposes. If object is
        % not scalar, a unanimous value is returned, or an alternative
        % (default is missing).

            arguments
                this mag.meta.Data {mustBeVector}
                property (1, 1) string
                alternative = missing()
            end

            values = [this.(property)];

            if isscalar(this) || isempty(values)

                value = values;
                return;
            end

            uniqueValues = unique(values);

            if isscalar(uniqueValues)
                value = uniqueValues;
            else

                if ismissing(alternative) && mag.internal.isMissingCompatible(values)
                    value = feval(class(values), alternative);
                else
                    value = alternative;
                end
            end
        end
    end

    methods (Hidden, Sealed)

        function sortedThis = sort(this, varargin)
        % SORT Override default sorting algorithm.

            [~, idxSort] = sort([this.Timestamp], varargin{:});
            sortedThis = this(idxSort);
        end
    end
end
