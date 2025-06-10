classdef (Abstract, HandleCompatible) LegendSupport
% LEGENDSUPPORT Add support for legend customization for an axis.

    properties
        % LEGEND Display names for legend.
        Legend (1, :) string = string.empty()
        % LEGENDLOCATION Location of legend.
        LegendLocation (1, 1) string = "best"
        % LEGENDORIENTATION Orientation of legend.
        LegendOrientation (1, 1) string = "vertical"
    end

    methods (Access = protected)

        function l = applyLegendStyle(this, axes)
        % APPLYLEGENDSTYLE Apply specified style to an axis, to customize
        % legend appearance.

            if isempty(this.Legend)
                l = matlab.graphics.illustration.Legend.empty();
            else
                l = legend(axes, this.Legend, Location = this.LegendLocation, Orientation = this.LegendOrientation);
            end
        end
    end
end
