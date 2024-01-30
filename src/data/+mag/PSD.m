classdef PSD < mag.Data
% PSD Class containing MAG PSD data.

    properties
        Data table
    end

    properties (Dependent)
        % FREQUENCY Frequency values.
        Frequency (:, 1) double
        % X x-axis component of the power spectral density.
        X (:, 1) double
        % Y y-axis component of the power spectral density.
        Y (:, 1) double
        % Z z-axis component of the power spectral density.
        Z (:, 1) double
        IndependentVariable
        DependentVariables
    end

    methods

        function this = PSD(psdData)

            arguments
                psdData
            end

            this.Data = psdData;
        end

        function independentVariable = get.IndependentVariable(this)
            independentVariable = this.Frequency;
        end

        function dependentVariables = get.DependentVariables(this)
            dependentVariables = this.Data{:, ["x", "y", "z"]};
        end

        function f = get.Frequency(this)
            f = this.Data.f;
        end

        function x = get.X(this)
            x = this.Data.x;
        end

        function y = get.Y(this)
            y = this.Data.y;
        end

        function z = get.Z(this)
            z = this.Data.z;
        end
    end

    methods (Hidden, Sealed)

        function tabularThis = tabular(this)
        % TABULAR Convert data to tabular.

            tabularThis = this.Data;
        end

        function tableThis = table(this)
        % TABLE Convert data to table.

            tableThis = this.Data;
        end
    end
end
