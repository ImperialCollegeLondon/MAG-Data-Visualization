classdef Separate < mag.process.Step
% SEPARATE Add row with missing data at end of tabular to separate
% different files. Avoid continuous lines when gap between files is large.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % DISCRIMINATIONVARIABLE Name of variable to increase in row.
        DiscriminationVariable (1, 1) string
        % QUALITYVARIABLE Name of quality variable.
        QualityVariable string {mustBeScalarOrEmpty}
        % VARIABLES Variables to be set to missing.
        Variables (1, :) string
    end

    methods

        function this = Separate(options)

            arguments
                options.?mag.process.Separate
            end

            this.assignProperties(options);
        end

        function value = get.Name(~)
            value = "Add Missing Row to Separate Files";
        end

        function value = get.Description(this)
            value = "Add extra row with missing values for " + join(compose("""%s""", this.Variables), ", ") + ".";
        end

        function value = get.DetailedDescription(this)
            value = this.Description + " This is to avoid continuous lines when gap between files is large.";
        end

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.Separate
                data tabular
                ~
            end

            if isequal(this.Variables, "*")

                locMissingCompatible = varfun(@mag.internal.isMissingCompatible, data, OutputFormat = "uniform");
                variables = data.Properties.VariableNames(locMissingCompatible);

                variables(variables == this.DiscriminationVariable) = [];
            else
                variables = this.Variables;
            end

            finalRow = data(end, :);

            if isdatetime(finalRow.(this.DiscriminationVariable)) || isduration(finalRow.(this.DiscriminationVariable))
                smallValue = mag.time.Constant.Eps;
            else
                smallValue = eps();
            end

            finalRow.(this.DiscriminationVariable) = finalRow.(this.DiscriminationVariable) + smallValue;
            finalRow{:, variables} = missing();

            if ~isempty(this.QualityVariable)
                finalRow.(this.QualityVariable) = mag.meta.Quality.Artificial;
            end

            data = [data; finalRow];
        end
    end
end
