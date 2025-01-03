classdef Instrument < handle & matlab.mixin.Copyable & matlab.mixin.CustomDisplay & ...
        mag.mixin.SetGet & mag.mixin.Crop & mag.mixin.Signal
% INSTRUMENT Class containing MAG instrument data.

    properties
        % EVENTS Event data.
        Events (1, :) mag.event.Event
        % METADATA Meta data.
        MetaData mag.meta.Instrument {mustBeScalarOrEmpty}
        % SCIENCE Science data.
        Science (1, :) mag.Science
        % HK Housekeeping data.
        HK (1, :) mag.HK
    end

    properties (Dependent, SetAccess = private)
        % HASDATA Logical denoting whether instrument has any data.
        HasData (1, 1) logical
        % HASMETADATA Logical denoting whether instrument has meta data.
        HasMetaData (1, 1) logical
        % HASSCIENCE Logical denoting whether instrument has science data.
        HasScience (1, 1) logical
        % HASHK Logical denoting whether instrument has HK data.
        HasHK (1, 1) logical
        % TIMERANGE Time range covered by science data.
        TimeRange (1, 2) datetime
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.Instrument
            end

            this.assignProperties(options);
        end

        function hasData = get.HasData(this)
            hasData = this.HasMetaData || this.HasScience || this.HasHK;
        end

        function hasMetaData = get.HasMetaData(this)
            hasMetaData = ~isempty(this.MetaData);
        end

        function hasScience = get.HasScience(this)
            hasScience = ~isempty(this.Science) && any([this.Science.HasData]);
        end

        function hasHK = get.HasHK(this)
            hasHK = ~isempty(this.HK) && any([this.HK.HasData]);
        end

        function timeRange = get.TimeRange(this)

            if this.HasScience

                firstTimes = arrayfun(@(x) x.Time(1), this.Science, UniformOutput = true);
                lastTimes = arrayfun(@(x) x.Time(end), this.Science, UniformOutput = true);

                timeRange = [min(firstTimes), max(lastTimes)];
            else
                timeRange = [NaT(TimeZone = "UTC"), NaT(TimeZone = "UTC")];
            end
        end

        function crop(this, filters)
        % CROP Crop data based on selected filters for primary and
        % secondary science.

            arguments
                this (1, 1) mag.Instrument
            end

            arguments (Repeating)
                filters
            end

            this.cropScience(filters{:});
            this.cropToMatch();
        end

        function cropScience(this, filters)
        % CROPSCIENCE Crop only science data based on selected time
        % filters.

            arguments
                this (1, 1) mag.Instrument
            end

            arguments (Repeating)
                filters
            end

            nScience = numel(this.Science);
            [scienceFilters{1:nScience}] = this.splitFilters(filters, nScience);

            for s = 1:numel(this.Science)
                this.Science(s).crop(scienceFilters{s});
            end
        end

        function cropToMatch(this, startTime, endTime)
        % CROPTOMATCH Crop meta data, events and HK based on science
        % timestamps or specified timestamps.

            arguments
                this (1, 1) mag.Instrument
                startTime (1, 1) datetime = this.TimeRange(1)
                endTime (1, 1) datetime = this.TimeRange(2)
            end

            timePeriod = timerange(startTime, endTime, "closed");

            % Filter events.
            if ~isempty(this.Events)
                this.Events = this.Events.crop(timePeriod);
            end

            % Filter HK.
            this.HK.crop(timePeriod);

            % Adjust meta data.
            if ~isempty(this.MetaData)
                this.MetaData.Timestamp = startTime;
            end
        end

        function resample(this, targetFrequency)

            arguments
                this (1, 1) mag.Instrument
                targetFrequency (1, 1) double
            end

            for s = this.Science
                s.resample(targetFrequency);
            end

            for hk = this.HK
                hk.resample(targetFrequency);
            end
        end

        function downsample(this, targetFrequency)

            arguments
                this (1, 1) mag.Instrument
                targetFrequency (1, 1) double
            end

            for s = this.Science
                s.downsample(targetFrequency);
            end

            for hk = this.HK
                hk.downsample(targetFrequency);
            end
        end
    end

    methods (Hidden, Sealed, Static)

        function loadedObject = loadobj(object)
        % LOADOBJ Override default loading from MAT file.

            if isa(object, "mag.Instrument")
                loadedObject = object;
            else

                if ~isfield(object, "Science")

                    science = [object.Primary, object.Secondary];
                    object = rmfield(object, ["Primary", "Secondary"]);

                    args = namedargs2cell(object);
                    loadedObject = mag.imap.Instrument(args{:}, Science = science);
                else

                    args = namedargs2cell(object);
                    loadedObject = mag.imap.Instrument(args{:});
                end
            end
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);

            copiedThis.MetaData = copy(this.MetaData);
            copiedThis.Events = copy(this.Events);
            copiedThis.Science = copy(this.Science);
            copiedThis.HK = copy(this.HK);
        end
    end
end
