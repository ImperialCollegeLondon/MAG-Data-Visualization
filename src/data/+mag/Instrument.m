classdef (Sealed) Instrument < handle & matlab.mixin.Copyable & matlab.mixin.CustomDisplay & ...
        mag.mixin.SetGet & mag.mixin.Crop & mag.mixin.Signal
% INSTRUMENT Class containing MAG instrument data.

    properties
        % EVENTS Event data.
        Events (1, :) mag.event.Event
        % METADATA Meta data.
        MetaData mag.meta.Instrument {mustBeScalarOrEmpty}
        % SCIENCE Science data.
        Science (1, :) mag.Science
        % IALIRT I-ALiRT data.
        IALiRT mag.IALiRT {mustBeScalarOrEmpty}
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
        % HASIALIRT Logical denoting whether instrument has I-ALiRT data.
        HasIALiRT (1, 1) logical
        % HASHK Logical denoting whether instrument has HK data.
        HasHK (1, 1) logical
        % TIMERANGE Time range covered by science data.
        TimeRange (1, 2) datetime
        % OUTBOARD Outboard science data (FOB, OBS, MAGo).
        Outboard mag.Science {mustBeScalarOrEmpty}
        % INBOARD Inboard science data (FIB, IBS, MAGi).
        Inboard mag.Science {mustBeScalarOrEmpty}
        % PRIMARY Primary science data.
        Primary mag.Science {mustBeScalarOrEmpty}
        % SECONDARY Secondary science data.
        Secondary mag.Science {mustBeScalarOrEmpty}
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.Instrument
            end

            this.assignProperties(options);
        end

        function hasData = get.HasData(this)
            hasData = this.HasMetaData || this.HasScience || this.HasIALiRT || this.HasHK;
        end

        function hasMetaData = get.HasMetaData(this)
            hasMetaData = ~isempty(this.MetaData);
        end

        function hasScience = get.HasScience(this)
            hasScience = ~isempty(this.Science) && all([this.Science.HasData]);
        end

        function hasIALiRT = get.HasIALiRT(this)
            hasIALiRT = ~isempty(this.IALiRT);
        end

        function hasHK = get.HasHK(this)
            hasHK = ~isempty(this.HK) && any(this.HK.HasData);
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

        function outboard = get.Outboard(this)
            outboard = this.Science.select("Outboard");
        end

        function inboard = get.Inboard(this)
            inboard = this.Science.select("Inboard");
        end

        function primary = get.Primary(this)
            primary = this.Science.select("Primary");
        end

        function secondary = get.Secondary(this)
            secondary = this.Science.select("Secondary");
        end

        function fillWarmUp(this, timePeriod, filler)
        % FILLWARMUP Replace beginning of science mode with filler
        % variable.

            arguments
                this (1, 1) mag.Instrument
                timePeriod (1, 1) duration = minutes(1)
                filler (1, 1) double = missing()
            end

            for s = this.Science
                s.replace(timePeriod, filler);
            end
        end

        function crop(this, primaryFilter, secondaryFilter)
        % CROP Crop data based on selected filters for primary and
        % secondary science.

            arguments
                this (1, 1) mag.Instrument
                primaryFilter
                secondaryFilter = primaryFilter
            end

            this.cropScience(primaryFilter, secondaryFilter);
            this.cropToMatch();
        end

        function cropScience(this, primaryFilter, secondaryFilter)
        % CROPSCIENCE Crop only science data based on selected time
        % filters.

            arguments
                this (1, 1) mag.Instrument
                primaryFilter
                secondaryFilter = primaryFilter
            end

            % Filter science.
            if ~isempty(this.Primary)
                this.Primary.crop(primaryFilter);
            end

            if ~isempty(this.Secondary)
                this.Secondary.crop(secondaryFilter);
            end

            % Filter I-ALiRT.
            if this.HasIALiRT
                this.IALiRT.crop(primaryFilter, secondaryFilter);
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
                    loadedObject = mag.Instrument(args{:}, Science = science);
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
            copiedThis.IALiRT = copy(this.IALiRT);
            copiedThis.HK = copy(this.HK);
        end

        function header = getHeader(this)

            if isscalar(this) && this.HasScience && this.HasMetaData && ~isempty(this.Primary) && ~isempty(this.Secondary) && ...
                    ~isempty(this.Primary.MetaData) && ~isempty(this.Secondary.MetaData)

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                tag = char(compose(" in %s (%d, %d)", this.Primary.MetaData.Mode, this.Primary.MetaData.DataFrequency, this.Secondary.MetaData.DataFrequency));

                header = ['  ', className, tag, ' with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end
    end
end
