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
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@mag.Instrument(this);
            copiedThis.IALiRT = copy(this.IALiRT);
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
