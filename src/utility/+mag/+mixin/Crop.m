classdef (Abstract, HandleCompatible) Crop
% CROP Interface adding support for cropping of data.

    methods (Abstract)

        % CROP Crop data based on selected filter.
        crop(this, timeFilter)
    end

    methods (Hidden, Sealed, Static)

        function mustBeTimeFilter(value)
        % MUSTBETIMEFILTER Validate that input value is of supported type
        % and format for cropping.

            mustBeA(value, ["datetime", "duration", "timerange", "withtol"]);

            if isdatetime(value)

                if ~(isvector(value) && isequal(numel(value), 2))
                    throwAsCaller(MException("", "Time filter of type ""datetime"" must have two elements."));
                end
            elseif isduration(value)

                if ~(isscalar(value) || (isvector(value) && isequal(numel(value), 2)))
                    throwAsCaller(MException("", "Time filter of type ""duration"" must have one or two elements."));
                end
            else

                if ~isscalar(value)
                    throwAsCaller(MException("", "Time filter of type ""%s"" must have one or two elements.", class(value)));
                end
            end
        end

        function timePeriod = convertToTimeSubscript(timeFilter, time)
        % CONVERTTOTIMESUBSCRIPT Convert to subscript that can be used for
        % timetable cropping.

            arguments (Input)
                timeFilter {mag.mixin.Crop.mustBeTimeFilter}
                time datetime {mustBeVector(time, "allow-all-empties")}
            end

            arguments (Output)
                timePeriod (1, 1) {mustBeA(timePeriod, ["timerange", "withtol"])}
            end

            if isa(timeFilter, "timerange") || isa(timeFilter, "withtol")
                timePeriod = timeFilter;
            else

                [startTime, endTime] = mag.mixin.Crop.computeStartEndTime(timeFilter, time);
                timePeriod = timerange(startTime, endTime, "closed");
            end
        end

        function [startTime, endTime] = convertToStartEndTime(timeFilter, time)
        % CONVERTTOSTARTENDTIME Convert to start and end times of filter.

            arguments (Input)
                timeFilter {mag.mixin.Crop.mustBeTimeFilter}
                time datetime {mustBeVector(time, "allow-all-empties")}
            end

            arguments (Output)
                startTime (1, 1) datetime
                endTime (1, 1) datetime
            end

            if isa(timeFilter, "timerange")

                [startTime, endTime] = mag.mixin.Crop.getInternalTimes(timeFilter, ["first", "last"]);
            elseif isa(timeFilter, "withtol")

                [subscriptTimes, tolerance] = mag.mixin.Crop.getInternalTimes(timeFilter, ["subscriptTimes", "tol"]);

                startTime = subscriptTimes - tolerance;
                endTime = subscriptTimes + tolerance;
            else
                [startTime, endTime] = mag.mixin.Crop.computeStartEndTime(timeFilter, time);
            end
        end

        function varargout = splitFilters(filters, expectedNumber)
        % SPLITFILTERS Split filters by expected numbers.

            arguments
                filters (1, :) cell
                expectedNumber (1, 1) double
            end

            actualNumber = numel(filters);

            if ~isequal(actualNumber, 1) && ~isequal(actualNumber, expectedNumber)
                throwAsCaller(MException("", "Number of time filters (%d) does not match expected number (%d).", actualNumber, expectedNumber));
            end

            if isscalar(filters)

                for i = 1:expectedNumber
                    varargout{i} = filters{1}; %#ok<AGROW>
                end
            else

                for i = 1:expectedNumber
                    varargout{i} = filters{i}; %#ok<AGROW>
                end
            end
        end
    end

    methods (Static, Access = private)

        function [startTime, endTime] = computeStartEndTime(timeFilter, time)
        % COMPUTESTARTENDTIME Compute start and end times of datetime or
        % duration filter. A positive duration is from the start of the
        % data, and a negative one from its end.

            if isdatetime(timeFilter)
                [startTime, endTime] = deal(timeFilter(1), timeFilter(2));
            elseif isscalar(timeFilter) && (timeFilter >= 0)
                [startTime, endTime] = deal(min(time) + timeFilter, max(time));
            elseif isscalar(timeFilter)
                [startTime, endTime] = deal(min(time), max(time) + timeFilter);
            elseif timeFilter(2) >= 0
                [startTime, endTime] = deal(min(time) + timeFilter(1), min(time) + timeFilter(2));
            else
                [startTime, endTime] = deal(min(time) + timeFilter(1), max(time) + timeFilter(2));
            end
        end

        function varargout = getInternalTimes(timeFilter, fields)
        % GETINTERNALTIMES Get times from "timerange" or "withtol". They
        % have no public properties, so this reads their internal fields,
        % which may change between MATLAB releases.

            warningStatus = warning("off", "MATLAB:structOnObject");
            restoreWarning = onCleanup(@() warning(warningStatus));

            internals = struct(timeFilter);

            if ~all(isfield(internals, fields))
                error("mag:crop:UnsupportedFilter", "Cannot read times of ""%s"" in this MATLAB release. Use ""datetime"" or ""duration"" time filters instead.", class(timeFilter));
            end

            varargout = cellfun(@(f) internals.(f), cellstr(fields), UniformOutput = false);
        end
    end
end
