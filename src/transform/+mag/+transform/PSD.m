classdef PSD < mag.transform.Transformation
% PSD Compute the power spectral density (PSD) from science data.

    properties
        Start datetime {mustBeScalarOrEmpty} = datetime.empty()
        Duration (1, 1) duration = hours(1)
        FFTType (1, 1) double {mustBeGreaterThanOrEqual(FFTType, 1), mustBeLessThanOrEqual(FFTType, 3)} = 2
        NW (1, 1) double = 7/2
    end

    methods

        function this = PSD(options)

            arguments
                options.?mag.transform.PSD
            end

            this.assignProperties(options);
        end

        function psd = apply(this, science)

            arguments (Input)
                this (1, 1) mag.transform.PSD
                science (1, 1) mag.Science
            end

            arguments (Output)
                psd (1, :) mag.PSD
            end

            % Filter out data.
            if isempty(this.Start)

                t = science.Time;
                locFilter = true(size(science.Data, 1), 1);
            else

                t = (science.Time - this.Start);

                locFilter = t >= 0;

                if (this.Duration ~= 0)
                    locFilter = locFilter & (t < this.Duration);
                end
            end

            % Compute PSD.
            dt = seconds(median(diff(t(locFilter))));

            xyz = science.XYZ(locFilter, :);
            xyz(ismissing(xyz) | isinf(xyz)) = 0;

            [psd, f] = psdtsh(xyz, dt, this.FFTType, this.NW);
            psd = psd .^ 0.5;

            % Smoothing
            smoothingSpan = 101;
            smoothingDegree = 2;
            smoothingCutoff = 1E-2; %The cutoff value for low vs high frequency.

            if this.Duration > hours(2)
                relevantIndices = find(f<smoothingCutoff);
                smoothingMethod = 'none';
            else
                relevantIndices = find(f>smoothingCutoff);
                smoothingMethod = 'moving';
    
            end

            switch smoothingMethod
                case 'none'
                    xVec = psd(:, 1);
                    yVec = psd(:, 2);
                    zVec = psd(:, 3);
                case 'sgolay'
                    xVec = smooth(psd(:, 1),smoothingSpan,smoothingMethod,smoothingDegree);
                    yVec = smooth(psd(:, 2),smoothingSpan,smoothingMethod,smoothingDegree);
                    zVec = smooth(psd(:, 3),smoothingSpan,smoothingMethod,smoothingDegree);

                otherwise
                    xVec = smooth(psd(:, 1),smoothingSpan,smoothingMethod);
                    yVec = smooth(psd(:, 2),smoothingSpan,smoothingMethod);
                    zVec = smooth(psd(:, 3),smoothingSpan,smoothingMethod);
            end

            xVec = xVec(relevantIndices);
            yVec = yVec(relevantIndices);
            zVec = zVec(relevantIndices);
            f = f(relevantIndices);

            psd = mag.PSD(table(f, xVec, yVec, zVec, VariableNames = ["f", science.Settings.X, science.Settings.Y, science.Settings.Z]));
            
        end
    end
end
