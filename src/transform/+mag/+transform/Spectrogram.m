classdef Spectrogram < mag.transform.Transformation
% SPECTROGRAM Compute spectrogram from science data.

    properties
        % FREQUENCYLIMITS Frequency band limits.
        FrequencyLimits (1, 2) double = [missing(), missing()]
        % FREQUENCYPOINTS Number of frequency samples.
        FrequencyPoints (1, 1) double = 256
        % OVERLAP Number of overlapped samples.
        Overlap (1, 1) double = missing()
        % NORMALIZE Normalize data before computing spectrum to highlight
        % spikes.
        Normalize (1, 1) logical = true
        % WINDOW Length of window.
        Window (1, 1) double = missing()
    end

    methods

        function this = Spectrogram(options)

            arguments
                options.?mag.transform.Spectrogram
            end

            this.assignProperties(options);
        end

        function spectrum = apply(this, science)

            arguments (Input)
                this (1, 1) mag.transform.Spectrogram
                science (1, 1) mag.Science
            end

            arguments (Output)
                spectrum (1, :) mag.Spectrum
            end

            science = science.copy();
            spectrum = mag.Spectrum.empty();

            % Filter invalid data.
            xyz = science.XYZ;
            locRemove = any(ismissing(xyz), 2) | any(isinf(xyz), 2);

            science.Data(locRemove, :) = [];

            % Compute spectrogram for each axis.
            [fx, tx, px] = this.computeSpectrogram(science.Time, science.X);
            [fy, ty, py] = this.computeSpectrogram(science.Time, science.Y);
            [fz, tz, pz] = this.computeSpectrogram(science.Time, science.Z);

            assert(numel(px) == numel(py), "x- and y-axis PSD should have same size.");
            assert(numel(py) == numel(pz), "y- and z-axis PSD should have same size.");

            assert(isequal(fx, fy) && isequal(fy, fz), "Detected frequencies should be the same for each axis.");
            assert(isequal(tx, ty) && isequal(ty, tz), "Timestamps should be the same for each axis.");

            % Combine results for each axis.
            for i = 1:numel(fx)
                spectrum(end + 1) = mag.Spectrum(tx{i}, fx{i}, px{i}, py{i}, pz{i}); %#ok<AGROW>
            end
        end
    end

    methods (Access = private)

        function [f, t, p] = computeSpectrogram(this, time, field)

            [f, t, p] = deal({});

            % Normalize data.
            if this.Normalize

                if height(field) < 1000
                    field = normalize(field);
                else

                    k = ceil(height(field) / 100);

                    field = (field - movmean(field, k, "omitmissing")) ./ movstd(field, k, "omitmissing");
                    field(isnan(field)) = 0; % isnan identifies where 0/0 has occurred above
                end
            end

            % Find non-contiguous time-periods.
            idxChange = find(diff(time) > seconds(1)) + 1;
            idxChange = [1; idxChange; numel(time) + 1];

            % Loop over each time period, and compute individual
            % spectrogram.
            for i = 1:(numel(idxChange) - 1)

                idxPeriod1 = idxChange(i):(idxChange(i + 1) - 1);
                x = time(idxPeriod1);
                y = field(idxPeriod1);

                % Split time period by frequency change.
                idxFrequency = find(diff(diff(x)) > milliseconds(1));
                idxFrequency = [1; idxFrequency; numel(x) + 1]; %#ok<AGROW>

                for j = 1:(numel(idxFrequency) - 1)

                    % At least 8 data points are needed by "spectrogram"
                    % function.
                    if (idxFrequency(j + 1) - idxFrequency(j)) < 8
                        continue;
                    end

                    idxPeriod2 = idxFrequency(j):(idxFrequency(j + 1) - 1);
                    x_ = x(idxPeriod2);
                    y_ = y(idxPeriod2);

                    [f_, t_, p_] = this.doComputeSpectrogram(x_, y_);

                    f{end + 1} = f_; %#ok<AGROW>
                    t{end + 1} = [t_(1) - mag.time.Constant.Eps, t_]; %#ok<AGROW>
                    p{end + 1} = [NaN(numel(f_), 1), p_]; %#ok<AGROW>
                end
            end
        end

        function [f, t, p] = doComputeSpectrogram(this, x, y)

            rate = round(1 / mode(seconds(diff(x))));

            % Window.
            if ~ismissing(this.Window)
                w = this.Window;
            elseif rate > 100
                w = 25;
            else
                w = 5;
            end

            window = rate * w;

            % Overlap.
            N = numel(x);

            if ~ismissing(this.Overlap)
                overlap = this.Overlap;
            elseif N < 1e4
                overlap = 0.8;
            elseif N > 1e6
                overlap = 0.3;
            else
                overlap = 0.8 + (N * (0.8 - 0.3) / (1e4 - 1e6));
            end

            overlap = round(window * overlap);

            % Corrections.
            if window > numel(y)
                window = [];
            end

            if overlap >= numel(y)
                overlap = [];
            end

            % Spectrogram.
            [~, f, t, p] = spectrogram(y, window, overlap, 2 * this.FrequencyPoints, rate);
            t = x(1) + seconds(t);

            % Remove unwanted frequencies.
            if ~any(ismissing(this.FrequencyLimits))

                locF = (f >= this.FrequencyLimits(1)) & (f <= this.FrequencyLimits(2));
                f = f(locF);
                p = p(locF, :);
            end
        end
    end
end
