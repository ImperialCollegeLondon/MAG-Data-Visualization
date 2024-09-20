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

            if isdatetime(timeFilter)
                timePeriod = timerange(timeFilter(1), timeFilter(2), "closed");
            elseif isduration(timeFilter)

                if isscalar(timeFilter)

                    if timeFilter >= 0
                        timePeriod = timerange(min(time) + timeFilter, max(time), "closed");
                    else
                        timePeriod = timerange(min(time), max(time) + timeFilter, "closed");
                    end
                else

                    if timeFilter(2) >= 0
                        timePeriod = timerange(min(time) + timeFilter(1), min(time) + timeFilter(2), "closed");
                    else
                        timePeriod = timerange(min(time) + timeFilter(1), max(time) + timeFilter(2), "closed");
                    end
                end
            elseif isa(timeFilter, "timerange") || isa(timeFilter, "withtol")
                timePeriod = timeFilter;
            end
        end

        function [startTime, endTime] = convertToStartEndTime(timeFilter, time)
        % CONVERTTOTIMESUBSCRIPT Convert to subscript that can be used for
        % timetable cropping.

            arguments (Input)
                timeFilter {mag.mixin.Crop.mustBeTimeFilter}
                time datetime {mustBeVector(time, "allow-all-empties")}
            end

            arguments (Output)
                startTime (1, 1) datetime
                endTime (1, 1) datetime
            end

            warningStatus = warning("off", "MATLAB:structOnObject");
            restoreWarning = onCleanup(@() warning(warningStatus));

            if isdatetime(timeFilter)
                [startTime, endTime] = deal(timeFilter(1), timeFilter(2));
            elseif isduration(timeFilter)

                if isscalar(timeFilter)

                    if timeFilter >= 0

                        startTime = min(time) + timeFilter;
                        endTime = max(time);
                    else

                        startTime = min(time);
                        endTime = max(time) + timeFilter;
                    end
                else

                    if timeFilter(2) >= 0

                        startTime = min(time) + timeFilter(1);
                        endTime = min(time) + timeFilter(2);
                    else

                        startTime = min(time) + timeFilter(1);
                        endTime = max(time) + timeFilter(2);
                    end
                end
            elseif isa(timeFilter, "timerange")

                structTimeRange = struct(timeFilter);

                startTime = structTimeRange.first;
                endTime = structTimeRange.last;
            elseif isa(timeFilter, "withtol")

                structWithTol = struct(timeFilter);

                startTime = structWithTol.subscriptTimes - structWithTol.tol;
                endTime = structWithTol.subscriptTimes + structWithTol.tol;
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
end
