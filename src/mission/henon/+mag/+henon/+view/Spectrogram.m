classdef Spectrogram < mag.graphics.view.DualSensorSpectrogram
% SPECTROGRAM Show spectrogram of HENON magnetic field.

    methods

        function this = Spectrogram(results, options)

            arguments
                results (1, 1) mag.henon.Instrument
                options.?mag.henon.view.Spectrogram
            end

            args = namedargs2cell(options);
            this@mag.graphics.view.DualSensorSpectrogram(results, args{:});
        end
    end
end
