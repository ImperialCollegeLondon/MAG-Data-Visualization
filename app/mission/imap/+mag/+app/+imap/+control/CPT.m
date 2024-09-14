classdef CPT < mag.app.Control & mag.app.mixin.Filter
% CPT View-controller for generating Comprehensive Performance Test plots.

    properties (Constant, Access = private)
        % PRIMARYMODEPATTERN Mode cycling pattern for primary sensor.
        PrimaryModePattern (1, :) double = [2, 64, 4, 64, 4, 128]
        % SECONDARYMODEPATTERN Mode cycling pattern for secondary sensor.
        SecondaryModePattern (1, :) double = [2, 8, 1, 64, 4, 128]
        % RANGEPATTERN Range cycling pattern for both sensor.
        RangePattern (1, :) double = [3, 2, 1, 0]
    end

    properties (SetAccess = private)
        Layout matlab.ui.container.GridLayout
        PrimaryModePatternField matlab.ui.control.EditField
        SecondaryModePatternField matlab.ui.control.EditField
        RangePatternField matlab.ui.control.EditField
    end

    methods

        function instantiate(this, parent)

            this.Layout = this.createDefaultGridLayout(parent);

            % Filter.
            this.addFilterButtons(this.Layout, StartFilterRow = 1);

            % Primary mode pattern.
            primaryModeLabel = uilabel(this.Layout, Text = "Primary mode pattern:", ...
                Tooltip = "Determine primary mode cycling based on this pattern.");
            primaryModeLabel.Layout.Row = 2;
            primaryModeLabel.Layout.Column = 1;

            this.PrimaryModePatternField = uieditfield(this.Layout, Value = this.encodeForEditField(this.PrimaryModePattern), ...
                ValueChangingFcn = @(~, value) this.validatePattern(value));
            this.PrimaryModePatternField.Layout.Row = 2;
            this.PrimaryModePatternField.Layout.Column = [2, 3];

            % Secondary mode pattern.
            secondryModeLabel = uilabel(this.Layout, Text = "Secondary mode pattern:", ...
                Tooltip = "Determine secondary mode cycling based on this pattern.");
            secondryModeLabel.Layout.Row = 3;
            secondryModeLabel.Layout.Column = 1;

            this.SecondaryModePatternField = uieditfield(this.Layout, Value = this.encodeForEditField(this.SecondaryModePattern), ...
                ValueChangingFcn = @(~, value) this.validatePattern(value));
            this.SecondaryModePatternField.Layout.Row = 3;
            this.SecondaryModePatternField.Layout.Column = [2, 3];

            % Range pattern.
            rangeLabel = uilabel(this.Layout, Text = "Range pattern:", ...
                Tooltip = "Determine range cycling based on this pattern.");
            rangeLabel.Layout.Row = 4;
            rangeLabel.Layout.Column = 1;

            this.RangePatternField = uieditfield(this.Layout, Value = this.encodeForEditField(this.RangePattern), ...
                ValueChangingFcn = @(~, value) this.validatePattern(value));
            this.RangePatternField.Layout.Row = 4;
            this.RangePatternField.Layout.Column = [2, 3];
        end

        function command = getVisualizeCommand(this, results)

            arguments (Input)
                this
                results (1, 1) mag.imap.Analysis
            end

            arguments (Output)
                command (1, 1) mag.app.Command
            end

            startFilter = this.getFilters();

            primaryModePattern = this.decodeFromEditField(this.PrimaryModePatternField.Value);
            secondaryModePattern = this.decodeFromEditField(this.SecondaryModePatternField.Value);
            rangePattern = this.decodeFromEditField(this.RangePatternField.Value);

            command = mag.app.Command(Functional = @mag.imap.view.cptPlots, ...
                PositionalArguments = {results}, ...
                NamedArguments = struct(Filter = startFilter, PrimaryModePattern = primaryModePattern, SecondaryModePattern = secondaryModePattern, RangePattern = rangePattern));
        end
    end

    methods (Access = private)

        function validatePattern(~, changingData)

            value = changingData.Value;
            pattern = asManyOfPattern(digitsPattern() + optionalPattern(characterListPattern(",") + whitespacePattern()));

            if ~matches(value, pattern)
                error("Value must match the pattern '1, 2, 3'.");
            end
        end
    end

    methods (Static, Access = private)

        function value = encodeForEditField(value)
            value = join(compose("%i", value), ", ");
        end

        function value = decodeFromEditField(value)
            value = str2double(split(value, ", "))';
        end
    end
end


