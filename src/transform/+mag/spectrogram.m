function spectrum = spectrogram(data, options)
% SPECTROGRAM Calculate spectrogram for given signal, as a function of time
% and frequency.

    arguments (Input)
        data (1, 1) mag.Science
        options.?mag.transform.Spectrogram
    end

    arguments (Output)
        spectrum (1, :) mag.Spectrum
    end

    try

        args = namedargs2cell(options);
        transformation = mag.transform.Spectrogram(args{:});

        spectrum = transformation.apply(data);
    catch exception
        rethrow(exception);
    end
end
