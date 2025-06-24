classdef (Abstract, HandleCompatible) TimeSeriesOperationSupport
% TIMESERIESOPERATIONSUPPORT Interface adding support for operations on
% "mag.TimeSeries" subclasses.

% Assume that this class has access to methods and properties of
% "mag.TimeSeries":
%#ok<*MCNPN>

    methods (Sealed)

        function result = join(this, those)

            arguments
                this {mustBeNonempty}
            end

            arguments (Repeating)
                those
            end

            % If no "those" is provided and "this" is an array, combine all
            % "these" data.
            if isempty(those) && ~isscalar(this)

                result = this(1).copy();
                result.Data = sortrows(vertcat(this.Data));

                return;
            end

            expectedClass = class(this);

            if isscalar(this) && all(cellfun(@(x) isa(x, expectedClass), those))

                thoseData = cellfun(@(x) x.Data, those, UniformOutput = false);
                joinedData = sortrows(vertcat(this.Data, thoseData{:}));

                result = this.copy();
                result.Data = joinedData;
            else
                error("mag:join:UnsupportedType", """join"" is only supported between mag.TimeSeries objects.");
            end
        end
    end

    methods (Hidden, Sealed)

        function result = plus(this, that)

            arguments
                this (1, 1)
                that
            end

            operation = @(this, that) sortrows(this.Data + that.Data);
            result = this.performOperationOrFallbackToBuiltin(that, operation, "plus");
        end

        function result = minus(this, that)

            arguments
                this (1, 1)
                that
            end

            operation = @(this, that) sortrows(this.Data - that.Data);
            result = this.performOperationOrFallbackToBuiltin(that, operation, "minus");
        end
    end

    methods (Access = private)

        function result = performOperationOrFallbackToBuiltin(this, that, operation, functionName, varargin)

            result = [];

            if isscalar(this) && all(isa(that, class(this)))

                result = this.copy();
                result.Data = operation(this, that);

                return;
            end

            try
                result = builtin(functionName, this, that, varargin{:});
            catch exception
                exception.throwAsCaller();
            end
        end
    end
end
