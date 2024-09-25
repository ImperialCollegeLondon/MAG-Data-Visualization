classdef Separate < mag.process.Step
% SEPARATE Add row with missing data at end of tabular to separate
% different files. Optionally, add missing row before large time gaps.
% Avoid continuous lines when gap between files is large.

    properties (Dependent)
        Name
        Description
        DetailedDescription
    end

    properties
        % DISCRIMINATIONVARIABLE Name of variable to increase in row.
        DiscriminationVariable (1, 1) string
        % LARGEDISCRIMIATETHRESHOLD Value above which gaps in
        % discrimination variable are considered large.
        LargeDiscriminateThreshold {mustBeScalarOrEmpty, mustBeA(LargeDiscriminateThreshold, ["double", "duration"])} = double.empty()
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

            if isempty(data)
                return;
            end

            rows = {};

            % Add missing after final row.
            rows{end + 1} = data(end, :);

            % Add missing after long pauses.
            if ~isempty(this.LargeDiscriminateThreshold)

                discriminationVar = data.(this.DiscriminationVariable);

                locGap = diff(discriminationVar) > this.LargeDiscriminateThreshold;
                idxGap = find([locGap; false]);

                for g = idxGap(:)'
                    rows{end + 1} = data(g, :); %#ok<AGROW>
                end
            end

            % Process.
            data = this.addMissingRows(data, rows);
        end
    end

    methods (Access = private)

        function missingVariables = getMissingVariables(this, data)
        % GETMISSINGVARIABLES Variables to be set to missing, after
        % validation.

            if isequal(this.Variables, "*")

                locMissingCompatible = varfun(@mag.internal.isMissingCompatible, data, OutputFormat = "uniform");
                missingVariables = data.Properties.VariableNames(locMissingCompatible);

                missingVariables(missingVariables == this.DiscriminationVariable) = [];
            else
                missingVariables = this.Variables;
            end
        end

        function data = addMissingRows(this, data, rows)

            if isdatetime(data.(this.DiscriminationVariable)) || isduration(data.(this.DiscriminationVariable))
                smallValue = mag.time.Constant.Eps;
            else
                smallValue = eps();
            end

            for r = 1:numel(rows)

                missingRow = rows{r};

                missingRow.(this.DiscriminationVariable) = missingRow.(this.DiscriminationVariable) + smallValue;
                missingRow{:, this.getMissingVariables(data)} = missing();

                if ~isempty(this.QualityVariable)
                    missingRow.(this.QualityVariable) = mag.meta.Quality.Artificial;
                end

                data = [data; missingRow]; %#ok<AGROW>
            end
        end
    end
end
