classdef Separate < mag.process.Step
% SEPARATE Add row with missing data at end of tabular to separate
% different files. Optionally, add missing row before large time gaps.
% Avoid continuous lines when gap between files is large.

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

        function data = apply(this, data, ~)

            arguments
                this (1, 1) mag.process.Separate
                data tabular
                ~
            end

            if isempty(data)
                return;
            end

            % Add missing after final row.
            idxRows = height(data);

            % Add missing after long pauses.
            if ~isempty(this.LargeDiscriminateThreshold)

                discriminationVar = data.(this.DiscriminationVariable);

                locGap = diff(discriminationVar) > this.LargeDiscriminateThreshold;
                idxRows = [idxRows; find([locGap; false])];
            end

            % Process.
            data = this.addMissingRows(data, idxRows);
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

        function data = addMissingRows(this, data, idxRows)
        % ADDMISSINGROWS Add a missing row just after each selected row, at
        % the end of the data. Rows are added at once, as adding them one
        % by one copies the data each time.

            if isdatetime(data.(this.DiscriminationVariable)) || isduration(data.(this.DiscriminationVariable))
                smallValue = mag.time.Constant.Eps;
            else
                smallValue = eps();
            end

            missingRows = data(idxRows, :);

            missingRows.(this.DiscriminationVariable) = missingRows.(this.DiscriminationVariable) + smallValue;
            missingRows{:, this.getMissingVariables(data)} = missing();
            missingRows{:, varfun(@(x) isenum(x) & isa(x, "double"), data, OutputFormat = "uniform")} = NaN();

            if ~isempty(this.QualityVariable)
                missingRows.(this.QualityVariable) = repmat(mag.meta.Quality.Artificial, height(missingRows), 1);
            end

            data = [data; missingRows];
        end
    end
end
