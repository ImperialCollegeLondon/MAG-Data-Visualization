classdef Instrument < mag.Instrument
% INSTRUMENT Class containing IMAP instrument data.

    properties
        % IALIRT I-ALiRT data.
        IALiRT mag.imap.IALiRT {mustBeScalarOrEmpty}
    end

    properties (Dependent, SetAccess = private)
        % HASIALIRT Logical denoting whether instrument has I-ALiRT data.
        HasIALiRT (1, 1) logical
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
                options.?mag.imap.Instrument
            end

            this.assignProperties(options);
        end

        function hasIALiRT = get.HasIALiRT(this)
            hasIALiRT = ~isempty(this.IALiRT);
        end

        function outboard = get.Outboard(this)
            outboard = this.Science.select(Sensor = "OBS");
        end

        function inboard = get.Inboard(this)
            inboard = this.Science.select(Sensor = "IBS");
        end

        function primary = get.Primary(this)
            primary = this.Science.select(Primary = true);
        end

        function secondary = get.Secondary(this)
            secondary = this.Science.select(Primary = false);
        end

        function cropScience(this, filters)
        % CROPSCIENCE Crop only science data based on selected time
        % filters.

            arguments
                this (1, 1) mag.imap.Instrument
            end

            arguments (Repeating)
                filters
            end

            % Filter science.
            cropScience@mag.Instrument(this, filters{:});

            % Filter I-ALiRT.
            if this.HasIALiRT
                this.IALiRT.crop(filters{:});
            end
        end

        function modes = getAllModes(this)
        % GETALLMODES Get all modes as separate data.

            arguments (Input)
                this (1, 1) mag.imap.Instrument
            end

            arguments (Output)
                modes (1, :) mag.imap.Instrument
            end

            modes = mag.imap.Instrument.empty();

            % Find duration for each mode.
            [primaryPeriods, primaryEvents] = findModePeriods(this.Primary);
            [secondaryPeriods, secondaryEvents] = findModePeriods(this.Secondary);

            if isempty(primaryPeriods) || isempty(secondaryPeriods)
                return;
            end

            % Modes are paired by position, which is only valid when both
            % sensors have the same modes.
            if ~isequal(numel(primaryPeriods), numel(secondaryPeriods))

                warning("mag:imap:UnequalModes", "Data not split by mode, as primary (%d) and secondary (%d) sensors have different number of modes.", ...
                    numel(primaryPeriods), numel(secondaryPeriods));
                return;
            end

            % Split data into separate elements.
            for p = 1:numel(primaryPeriods)

                data = this.applyTimeRange(primaryPeriods{p}, secondaryPeriods{p});

                if isempty(data)
                    continue;
                end

                setModeMetadata(data.Primary.Metadata, primaryEvents(p, :));
                setModeMetadata(data.Secondary.Metadata, secondaryEvents(p, :));

                modes(end + 1) = data; %#ok<AGROW>
            end
        end

        function modeCycling = getModeCycling(this, options)
        % GETMODECYCLING Get mode cycling data.

            arguments (Input)
                this (1, 1) mag.imap.Instrument
                options.PrimaryPattern (1, :) double = [2, 64, 2, 4, 64, 4, 4, 128]
                options.SecondaryPattern (1, :) double = [2, 8, 2, 1, 64, 1, 4, 128]
            end

            arguments (Output)
                modeCycling mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            modeCycling = this.applyTimeRange( ...
                findPatternPeriod(this.Primary.Events, "DataFrequency", options.PrimaryPattern), ...
                findPatternPeriod(this.Secondary.Events, "DataFrequency", options.SecondaryPattern));
        end

        function rangeCycling = getRangeCycling(this, options)
        % GETRANGECYCLING Get range cycling data.

            arguments (Input)
                this (1, 1) mag.imap.Instrument
                options.Pattern (1, :) double = [3, 2, 1, 0]
            end

            arguments (Output)
                rangeCycling mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            if ~this.HasScience

                rangeCycling = mag.imap.Instrument.empty();
                return;
            end

            rangeCycling = this.applyTimeRange( ...
                findPatternPeriod(this.Primary.Events, "Range", options.Pattern), ...
                findPatternPeriod(this.Secondary.Events, "Range", options.Pattern), ...
                EnforceSizeMatch = true);
        end

        function finalNormal = getFinalNormalMode(this)
        % GETFINALNORMALMODE Get normal mode at the end of analysis.

            arguments (Input)
                this (1, 1) mag.imap.Instrument
            end

            arguments (Output)
                finalNormal mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            finalNormal = this.applyTimeRange( ...
                findFinalNormalMode(this.Primary.Events, this.Primary.Time(end)), ...
                findFinalNormalMode(this.Secondary.Events, this.Secondary.Time(end)));
        end
    end

    methods (Access = private)

        function result = applyTimeRange(this, primaryPeriod, secondaryPeriod, options)
        % APPLYTIMERANGE Apply time range to a copy of science data and its
        % events. Return empty if either sensor has no data left.

            arguments (Input)
                this (1, 1) mag.imap.Instrument
                primaryPeriod (1, 1) timerange
                secondaryPeriod (1, 1) timerange
                options.EnforceSizeMatch (1, 1) logical = false
            end

            arguments (Output)
                result mag.imap.Instrument {mustBeScalarOrEmpty}
            end

            result = this.copy();
            result.crop(primaryPeriod, secondaryPeriod);

            if ~result.Primary.HasData || ~result.Secondary.HasData
                result = mag.imap.Instrument.empty();
            elseif options.EnforceSizeMatch

                if numel(result.Primary.Time) > numel(result.Secondary.Time)
                    result.Primary.Data = result.Primary.Data(1:numel(result.Secondary.Time), :);
                elseif numel(result.Primary.Time) < numel(result.Secondary.Time)
                    result.Secondary.Data = result.Secondary.Data(1:numel(result.Primary.Time), :);
                end
            end
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@mag.Instrument(this);
            copiedThis.IALiRT = copy(this.IALiRT);
        end

        function header = getHeader(this)

            if isscalar(this) && this.HasScience && this.HasMetadata && ~isempty(this.Primary) && ~isempty(this.Secondary) && ...
                    ~isempty(this.Primary.Metadata) && ~isempty(this.Secondary.Metadata)

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                tag = char(compose(" in %s (%d, %d)", this.Primary.Metadata.Mode, this.Primary.Metadata.DataFrequency, this.Secondary.Metadata.DataFrequency));

                header = ['  ', className, tag, ' with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end
    end
end

function [periods, modeEvents] = findModePeriods(data)
% FINDMODEPERIODS Find period of each mode, from its start until the start
% of the next mode, or the end of the data.

    if isempty(data)

        periods = {};
        modeEvents = [];
        return;
    end

    events = data.Events;

    modeEvents = events(~ismissing(events.Duration), :);
    periods = repmat({timerange()}, 1, height(modeEvents));

    for e = 1:height(modeEvents)

        if e == height(modeEvents)

            idxTime = find(modeEvents.Time == modeEvents.Time(e), 1) + 1;

            if idxTime > height(modeEvents)
                endTime = data.Time(end);
            else
                endTime = modeEvents.Time(idxTime);
            end
        else
            endTime = modeEvents.Time(e + 1);
        end

        periods{e} = timerange(modeEvents.Time(e), endTime, "closedleft");
    end
end

function setModeMetadata(metadata, modeEvent)
% SETMODEMETADATA Set mode and frequencies from mode event.

    metadata.Mode = string(modeEvent{1, "Mode"});
    metadata.DataFrequency = modeEvent{1, "DataFrequency"};
    metadata.PacketFrequency = modeEvent{1, "PacketFrequency"};
end

function period = findPatternPeriod(events, variable, pattern)
% FINDPATTERNPERIOD Find period where values of an event variable follow
% the pattern. Use first occurrence of pattern only. If pattern ends with
% last event, include data until the end.

    idxPattern = strfind(events.(variable)', pattern);

    if isempty(idxPattern)
        period = mag.time.emptyTimerange();
    elseif (idxPattern(1) + numel(pattern)) > height(events)
        period = timerange(events.Time(idxPattern(1)), datetime("Inf", TimeZone = "UTC"), "closed");
    else
        period = timerange(events.Time(idxPattern(1)), events.Time(idxPattern(1) + numel(pattern)), "closedleft");
    end
end

function period = findFinalNormalMode(events, endTime)
% FINDFINALNORMALMODE Find last normal mode at 2 Hz, if one of the last
% three events is normal mode.

    if any(events{end-2:end, "Mode"} == "Normal")

        events = events((events.Mode == "Normal") & (events.DataFrequency == 2) & ~contains(events.Label, "Shutdown"), :);
        period = timerange(events.Time(end), endTime, "closed");
    else
        period = mag.time.emptyTimerange();
    end
end
