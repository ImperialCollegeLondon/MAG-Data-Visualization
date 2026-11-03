classdef Spectrogram < mag.graphics.view.DualSensorSpectrogram
% SPECTROGRAM Show spectrogram of Bartington magnetic field.

    methods

        function this = Spectrogram(results, options)

            arguments
                results (1, 1) mag.bart.Instrument
                options.?mag.bart.view.Spectrogram
            end

            args = namedargs2cell(options);
            this@mag.graphics.view.DualSensorSpectrogram(results, args{:});

            this.SensorNames = ["Input 1", "Input 2"];
            this.TitlePrefix = "Bartington";
        end
    end
end
