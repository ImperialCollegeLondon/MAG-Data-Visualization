classdef Spectrum < mag.Data
% SPECTRUM Class containing MAG spectrum data.

    properties
        % FREQUENCY Frequency values.
        Frequency (:, 1) double
        % TIME Timestamp of frequency snapshot.
        Time (1, :) datetime
        % X x-axis component of the power spectral density.
        X (:, :) double
        % Y y-axis component of the power spectral density.
        Y (:, :) double
        % Z z-axis component of the power spectral density.
        Z (:, :) double
    end

    properties (Dependent)
        IndependentVariable
        DependentVariables
    end

    methods

        function this = Spectrum(time, frequency, x, y, z)

            this.Time = time;
            this.Frequency = frequency;
            this.X = x;
            this.Y = y;
            this.Z = z;
        end

        function independentVariable = get.IndependentVariable(this)
            independentVariable = meshgrid(this.Time, this.Frequency);
        end

        function dependentVariables = get.DependentVariables(this)
            dependentVariables = cat(3, this.X, this.Y, this.Z);
        end
    end
end
