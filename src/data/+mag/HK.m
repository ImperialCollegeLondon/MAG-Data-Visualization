classdef (Abstract) HK < mag.TimeSeries & matlab.mixin.CustomDisplay
% HK Class containing MAG housekeeping data.

    methods

        function this = HK(hkData, metaData)

            arguments
                hkData timetable
                metaData (1, 1) mag.meta.HK
            end

            this.Data = hkData;
            this.MetaData = metaData;
        end

        function resample(this, targetFrequency)

            arguments
                this (1, 1) mag.HK
                targetFrequency (1, 1) double
            end

            if ~isempty(this.Data)

                timestamps = this.Time(1):seconds(1 / targetFrequency):this.Time(end);
                this.Data = retime(this.Data, timestamps, "linear");
            end
        end

        function downsample(this, targetFrequency)

            arguments
                this (1, 1) mag.HK
                targetFrequency (1, 1) double
            end

            this.resample(targetFrequency);
        end
    end

    methods (Sealed)

        function crop(this, timeFilter)

            arguments
                this mag.HK
                timeFilter {mag.mixin.Crop.mustBeTimeFilter}
            end

            for i = 1:numel(this)

                timePeriod = this.convertToTimeSubscript(timeFilter, this(i).Time);
                this(i).Data = this(i).Data(timePeriod, :);

                if isempty(this(i).Time)
                    this(i).MetaData.Timestamp = NaT(TimeZone = mag.time.Constant.TimeZone);
                else
                    this(i).MetaData.Timestamp = this(i).Time(1);
                end
            end
        end

        function hkType = getHKType(this, type)
        % GETHKTYPE Get specific type of HK. Default is power HK.

            arguments
                this mag.HK
                type (1, 1) string {mustBeMember(type, ["PROCSTAT", "PW", "SID15", "STATUS"])} = "PW"
            end

            if ~isempty(this)

                hkMetaData = [this.MetaData];
                hkType = this([hkMetaData.Type] == type);
            else
                hkType = mag.HK.empty();
            end
        end
    end

    methods (Sealed, Access = protected)

        function header = getHeader(this)

            if isscalar(this) && ~isempty(this.MetaData) && ~isempty(this.MetaData.Type)

                className = matlab.mixin.CustomDisplay.getClassNameForHeader(this);
                tag = char(compose("%s", this.MetaData.Type));

                header = ['  ', className, ' HK (', tag, ') with properties:'];
            else
                header = getHeader@matlab.mixin.CustomDisplay(this);
            end
        end

        function groups = getPropertyGroups(this)
            groups = getPropertyGroups@matlab.mixin.CustomDisplay(this);
        end

        function footer = getFooter(this)
            footer = getFooter@matlab.mixin.CustomDisplay(this);
        end

        function displayScalarObject(this)
            displayScalarObject@matlab.mixin.CustomDisplay(this);
        end

        function displayNonScalarObject(this)
            displayNonScalarObject@matlab.mixin.CustomDisplay(this);
        end

        function displayEmptyObject(this)
            displayEmptyObject@matlab.mixin.CustomDisplay(this);
        end

        function displayScalarHandleToDeletedObject(this)
            displayScalarHandleToDeletedObject@matlab.mixin.CustomDisplay(this);
        end
    end
end
