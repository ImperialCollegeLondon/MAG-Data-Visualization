classdef Spectrogram < mag.graphics.view.DualSensorSpectrogram
% SPECTROGRAM Show spectrogram of Vigil magnetic field.

    methods

        function this = Spectrogram(results, options)

            arguments
                results (1, 1) mag.vigil.Instrument
                options.?mag.vigil.view.Spectrogram
            end

            args = namedargs2cell(options);
            this@mag.graphics.view.DualSensorSpectrogram(results, args{:});
        end
    end
end
