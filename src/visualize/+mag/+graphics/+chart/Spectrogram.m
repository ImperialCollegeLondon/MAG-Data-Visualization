classdef Spectrogram < mag.graphics.chart.Chart
% SPECTROGRAM Definition of chart of "spectrogram" type.

    methods

        function this = Spectrogram(options)

            arguments
                options.?mag.graphics.chart.Spectrogram
            end

            this.assignProperties(options);
        end

        function graph = plot(this, data, axes, ~)

            arguments (Input)
                this (1, 1) mag.graphics.chart.Spectrogram
                data (1, :) mag.Spectrum
                axes (1, 1) matlab.graphics.axis.Axes
                ~
            end

            arguments (Output)
                graph (1, :) matlab.graphics.Graphics
            end

            hold(axes, "on");
            resetAxesHold = onCleanup(@() hold(axes, "off"));

            graph = matlab.graphics.chart.primitive.Surface.empty();

            % Plot.
            for d = data

                p = this.YVariables.applyAll(d);
                graph(end + 1) = surf(axes, d.Time, d.Frequency, pow2db(abs(p)), EdgeColor = "none"); %#ok<AGROW>
            end

            % Arrange.
            axes.XLimitMethod = "tight";
            axes.YLimitMethod = "tight";

            view(axes, [0, 90]);
        end
    end
end
