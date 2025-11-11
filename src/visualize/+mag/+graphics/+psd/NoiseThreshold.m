classdef NoiseThreshold
% NOISETHRESHOLD Definition of the noise threshold for a PSD.

    enumeration
        % DEFAULT Default noise threshold (10 pT/Hz^0.5).
        Default
        % HELIOSWARM HelioSwarm noise threshold.
        HelioSwarm
    end

    methods

        function threshold = getChart(this, parent)

            arguments
                this (1, 1) mag.graphics.psd.NoiseThreshold
                parent {mustBeScalarOrEmpty} = matlab.ui.Figure.empty()
            end

            color = "black";

            if ~isempty(parent)

                root = ancestor(parent, "figure");

                if ~isempty(root) && mag.internal.isThemeable(root) && isequal(root.Theme.BaseColorStyle, "dark")
                    color = fliplightness(color);
                end
            end

            switch this
                case mag.graphics.psd.NoiseThreshold.Default
                    threshold = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");
                case mag.graphics.psd.NoiseThreshold.HelioSwarm
                    threshold = mag.graphics.chart.Function(Callable = @mag.graphics.psd.NoiseThreshold.helioSwarmPiecewiseNoiseThreshold, LineStyle = "--", Color = color);
                otherwise
                    error("mag:graphics:UnknownPSDNoiseThreshold", "Unknown PSD noise threshold of type ""%s"".", this);
            end
        end
    end

    methods (Static, Access = private)

        function y = helioSwarmPiecewiseNoiseThreshold(x)

            y(x <= 1) = 1500e-3;
            y((x > 1) & (x <= 2)) = 15e-3;
            y(x > 2) = 7.5e-3;
        end
    end
end
