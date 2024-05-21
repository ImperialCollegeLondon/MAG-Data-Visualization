classdef Science < mag.TimeSeries & matlab.mixin.CustomDisplay
% SCIENCE Class containing MAG science data.

    properties (Dependent)
        % X x-axis component of the magnetic field.
        X (:, 1) double
        % Y y-axis component of the magnetic field.
        Y (:, 1) double
        % Z z-axis component of the magnetic field.
        Z (:, 1) double
        % XYZ x-, y- and z-axis components of the magnetic field.
        XYZ (:, 3) double
        % B Magnitude of the magnetic field.
        B (:, 1) double
        % DX x-axis derivative of the magnetic field.
        dX (:, 1) double
        % DY y-axis derivative of the magnetic field.
        dY (:, 1) double
        % DZ z-axis derivative of the magnetic field.
        dZ (:, 1) double
        % RANGE Range values of sensor.
        Range (:, 1) uint8
        % SEQUENCE Sequence number of vectors.
        Sequence (:, 1) uint16
        % COMPRESSION Compression flag denoting whether data is compressed.
        % "true" stands for compressed.
        Compression (:, 1) logical
        % QUALITY Quality flag denoting whether data is of high quality.
        Quality (:, 1) mag.meta.Quality
        % EVENTS Events detected.
        Events eventtable
    end

    properties (SetAccess = immutable)
        % SETTINGS Mapping of "timetable" properties to "mag.Science".
        Settings (1, 1) mag.setting.Science
    end

    methods

        function this = Science(scienceData, metaData, propertySettings)

            arguments
                scienceData timetable
                metaData (1, 1) mag.meta.Science
                propertySettings (1, 1) mag.setting.Science = mag.setting.Science()
            end

            this.Data = scienceData;
            this.MetaData = metaData;
            this.Settings = propertySettings;
        end

        function x = get.X(this)
            x = double(this.Data.(this.Settings.X));
        end

        function y = get.Y(this)
            y = double(this.Data.(this.Settings.Y));
        end

        function z = get.Z(this)
            z = double(this.Data.(this.Settings.Z));
        end

        function xyz = get.XYZ(this)
            xyz = double(this.Data{:, [this.Settings.X, this.Settings.Y, this.Settings.Z]});
        end

        function b = get.B(this)
            b = vecnorm(this.XYZ, 2, 2);
        end

        function dx = get.dX(this)
            dx = this.computeDerivative(this.X);
        end

        function dy = get.dY(this)
            dy = this.computeDerivative(this.Y);
        end

        function dz = get.dZ(this)
            dz = this.computeDerivative(this.Z);
        end

        function range = get.Range(this)
            range = uint8(this.Data.(this.Settings.Range));
        end

        function sequence = get.Sequence(this)
            sequence = this.Data.(this.Settings.Sequence);
        end

        function compression = get.Compression(this)
            compression = logical(this.Data.(this.Settings.Compression));
        end

        function set.Quality(this, quality)
            this.Data.(this.Settings.Quality) = quality;
        end

        function quality = get.Quality(this)
            quality = this.Data.(this.Settings.Quality);
        end

        function events = get.Events(this)
            events = this.Data.Properties.Events;
        end

        function crop(this, timeFilter)

            arguments
                this (1, 1) mag.Science
                timeFilter {mag.mixin.Crop.mustBeTimeFilter}
            end

            timePeriod = this.convertToTimeSubscript(timeFilter, this.Time);
            this.Data = this.Data(timePeriod, :);

            % Filter events, but do not remove mode or range that are still
            % ongoing.
            if isempty(this.Events) || isempty(this.Events(timePeriod, :))
                this.Data.Properties.Events = mag.Science.generateEmptyEventtable();
            else

                % Crop events.
                originalEvents = this.Events;
                this.Data.Properties.Events = originalEvents(timePeriod, :);

                if min(this.Data.Properties.Events.Time) > min(this.Time)

                    croppedEvents = setdiff(originalEvents, this.Events);
                    croppedEvents(croppedEvents.Time >= max(this.Time), :) = [];

                    % Find the earliest previous mode and range changes.
                    lastModeChange = croppedEvents(find(contains(croppedEvents.Label, "(" | ")"), 1, "last"), :);
                    lastRangeChange = croppedEvents(find(contains(croppedEvents.Label, "Range"), 1, "last"), :);

                    lastEvents = [lastModeChange; lastRangeChange];
                    lastEvents.Time = repmat(min(this.Time), height(lastEvents), 1) + ...
                        cumsum(repmat(mag.time.Constant.Eps, height(lastEvents), 1)); % add "eps" seconds so that they are not all the same

                    % Re-add events.
                    this.Data.Properties.Events = [lastEvents; this.Events];
                end
            end

            if isempty(this.Time)
                this.MetaData.Timestamp = NaT(TimeZone = mag.time.Constant.TimeZone);
            else
                this.MetaData.Timestamp = min(this.Time);
            end
        end

        function resample(this, targetFrequency)

            arguments
                this (1, 1) mag.Science
                targetFrequency (1, 1) double
            end

            actualFrequency = 1 / seconds(mode(this.dT));

            if actualFrequency == targetFrequency
                return;
            elseif actualFrequency > targetFrequency

                numerator = 1;
                denominator = actualFrequency / targetFrequency;
            else

                numerator = targetFrequency / actualFrequency;
                denominator = 1;
            end

            if (round(numerator) ~= numerator) || (round(denominator) ~= denominator)
                error("Calculated numerator (%.3f) and denominator (%.3f) must be integers.", numerator, denominator);
            end

            xyz = resample(this.Data(:, [this.Settings.X, this.Settings.Y, this.Settings.Z]), numerator, denominator);
            xyz = xyz(timerange(this.Time(1), this.Time(end), "closed"), :);

            resampledData = retime(this.Data, xyz.Time, "nearest");
            resampledData(:, [this.Settings.X, this.Settings.Y, this.Settings.Z]) = xyz;

            this.Data = resampledData;
            this.MetaData.DataFrequency = targetFrequency;
        end

        function downsample(this, targetFrequency)

            arguments
                this (1, 1) mag.Science
                targetFrequency (1, 1) double
            end

            dt = this.dT(this.Quality.isScience());
            this.mustBeConstantRate(milliseconds(dt));

            actualFrequency = 1 / seconds(mode(dt));
            decimationFactor = actualFrequency / targetFrequency;

            if actualFrequency == targetFrequency
                return;
            elseif round(decimationFactor) ~= decimationFactor
                error("Calculated decimation factor (%.3f) must be an integer.", decimationFactor);
            end

            a = ones(1, decimationFactor) / decimationFactor;
            b = conv(a, a);

            this.filter(b);

            this.Data = downsample(this.Data, decimationFactor);
            this.MetaData.DataFrequency = targetFrequency;
        end

        function filter(this, numeratorOrFilter, denominator)
        % FILTER Filter science data with specified numerator/denominator
        % pair, or filter object.

            arguments
                this (1, 1) mag.Science
                numeratorOrFilter (1, :) {mustBeA(numeratorOrFilter, ["double", "digitalFilter"])}
                denominator (1, :) double = double.empty()
            end

            if isa(numeratorOrFilter, "digitalFilter")
                arguments = {numeratorOrFilter};
            elseif isempty(denominator)
                arguments = {numeratorOrFilter, 1};
            else
                arguments = {numeratorOrFilter, denominator};
            end

            this.Data{:, [this.Settings.X, this.Settings.Y, this.Settings.Z]} = filter(arguments{:}, this.XYZ);

            if isa(numeratorOrFilter, "digitalFilter")
                numCoefficients = numel(numeratorOrFilter.Coefficients);
            else
                numCoefficients = numel(numeratorOrFilter);
            end

            if numCoefficients > height(this.Data)
                numCoefficients = height(this.Data);
            end

            this.Data{1:numCoefficients, [this.Settings.X, this.Settings.Y, this.Settings.Z]} = missing();
        end

        function replace(this, timeFilter, filler)
        % REPLACE Replace length of data specified by time filter with
        % filler variable.

            arguments
                this (1, 1) mag.Science
                timeFilter (1, 1) {mustBeA(timeFilter, ["duration", "timerange", "withtol"])}
                filler (1, 1) double = missing()
            end

            if isa(timeFilter, "duration")
                timePeriod = timerange(this.Time(1), this.Time(1) + timeFilter, "closed");
            elseif isa(timeFilter, "timerange") || isa(timeFilter, "withtol")
                timePeriod = timeFilter;
            end

            this.Data{timePeriod, [this.Settings.X, this.Settings.Y, this.Settings.Z]} = filler;
        end

        function data = computePSD(this, options)
        % COMPUTEPSD Compute the power spectral density of the magnetic
        % field measurements.

            arguments (Input)
                this (1, 1) mag.Science
                options.Start datetime {mustBeScalarOrEmpty} = datetime.empty()
                options.Duration (1, 1) duration = hours(1)
                options.FFTType (1, 1) double {mustBeGreaterThanOrEqual(options.FFTType, 1), mustBeLessThanOrEqual(options.FFTType, 3)} = 2
                options.NW (1, 1) double = 7/2
            end

            arguments (Output)
                data (1, 1) mag.PSD
            end

            % Filter out data.
            if isempty(options.Start)

                t = this.Time;
                locFilter = true(size(this.Data, 1), 1);
            else

                t = (this.Time - options.Start);

                locFilter = t > 0;

                if (options.Duration ~= 0)
                    locFilter = locFilter & (t < options.Duration);
                end
            end

            % Compute PSD.
            dt = seconds(median(diff(t(locFilter))));

            xyz = this.XYZ(locFilter, :);
            xyz(ismissing(xyz) | isinf(xyz)) = 0;

            [psd, f] = psdtsh(xyz, dt, options.FFTType, options.NW);
            psd = psd .^ 0.5;

            data = mag.PSD(table(f, psd(:, 1), psd(:, 2), psd(:, 3), VariableNames = ["f", this.Settings.X, this.Settings.Y, this.Settings.Z]));
        end
    end

    methods (Sealed)

        function name = getName(this, primaryOrSecondary)
        % GETNAME Return name of primary or secondary sensor.

            arguments (Input)
                this mag.Science {mustBeNonempty}
                primaryOrSecondary (1, 1) string {mustBeMember(primaryOrSecondary, ["Primary", "Secondary"])} = "Primary"
            end

            arguments (Output)
                name (1, 1) mag.meta.Sensor
            end

            % If no primary sensor is set, assume it's FOB.
            metaData = [this.MetaData];
            locPrimary = [metaData.Primary];

            switch nnz(locPrimary)
                case 0
                    primarySensor = mag.meta.Sensor.FOB;
                case 1

                    sensors = [metaData.Sensor];
                    primarySensor = sensors(locPrimary);
                otherwise
                    error("One and only one sensor can be primary.");
            end

            % Retrieve selected sensor.
            supportedSensors = enumeration("mag.meta.Sensor");

            switch primaryOrSecondary
                case "Primary"
                    locSelected = supportedSensors == primarySensor;
                case "Secondary"
                    locSelected = supportedSensors ~= primarySensor;
            end

            name = supportedSensors(locSelected);
        end

        function science = select(this, selected)
        % SELECT Return primary or secondary sensor.

            arguments (Input)
                this mag.Science {mustBeNonempty}
                selected (1, 1) string {mustBeMember(selected, ["Outboard", "Inboard", "Primary", "Secondary"])}
            end

            arguments (Output)
                science mag.Science {mustBeScalarOrEmpty}
            end

            metaData = [this.MetaData];

            if contains(selected, "board")
                locSelected = [metaData.Sensor] == ("F" + extract(selected, regexpPattern("O|I")) + "B");
            else
                locSelected = [metaData.Primary] == isequal(selected, "Primary");
            end

            science = this(locSelected);
        end
    end

    methods (Static)

        function emptyTable = generateEmptyEventtable()
        % GENERATEEMPTYEVENTTABLE Generate empty timetable for describing
        % science events.

            emptyTime = datetime.empty();
            emptyTime.TimeZone = mag.time.Constant.TimeZone;

            emptyTable = struct2table(struct(Time = emptyTime, ...
                Mode = categorical.empty(0, 1), ...
                DataFrequency = double.empty(0, 1), ...
                PacketFrequency = double.empty(0, 1), ...
                Duration = double.empty(0, 1), ...
                Range = double.empty(0, 1), ...
                Label = string.empty(0, 1), ...
                Reason = categorical.empty(0, 1)));

            emptyTable = table2timetable(emptyTable, RowTimes = "Time");
            emptyTable = eventtable(emptyTable, EventLabelsVariable = "Label");
        end
    end

    methods (Access = protected)

        function header = getHeader(this)

            if isscalar(this) && ~isempty(this.MetaData)

                if ~isempty(this.MetaData) && ~isempty(this.MetaData.Sensor) && ~isempty(this.MetaData.Setup) && ~isempty(this.MetaData.Setup.Model)
                    tag = char(compose(" from %s (%s) in %s (%d)", this.MetaData.Sensor, this.MetaData.Setup.Model, this.MetaData.Mode, this.MetaData.DataFrequency));
                elseif ~isempty(this.MetaData) && ~isempty(this.MetaData.Sensor)
                    tag = char(compose(" from %s in %s (%d)", this.MetaData.Sensor, this.MetaData.Mode, this.MetaData.DataFrequency));
                else
                    tag = char(compose(" in %s (%d)", this.MetaData.Mode, this.MetaData.DataFrequency));
                end

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                header = ['  ', className, tag, ' with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end
    end
end
