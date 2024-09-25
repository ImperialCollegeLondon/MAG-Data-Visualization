function psd = psd(data, options)
% PSD Compute the power spectral density (PSD) of the magnetic field
% measurements.

    arguments (Input)
        data (1, 1) mag.Science
        options.?mag.transform.PSD
    end

    arguments (Output)
        psd (1, :) mag.PSD
    end

    try

        args = namedargs2cell(options);
        transformation = mag.transform.PSD(args{:});

        psd = transformation.apply(data);
    catch exception
        rethrow(exception);
    end
end
