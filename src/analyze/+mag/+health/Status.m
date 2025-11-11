classdef Status
% STATUS Health check status.

    enumeration
        % PASS Health check passed.
        Pass (1, "#14b814")
        % FAIL Health check failed.
        Fail (0, "#e76a5f")
        % BORDERLINE Health check provisionally passed.
        Borderline (0.5, "#d99e14")
        % INCOMPLETE Health check could not be completed.
        Incomplete (-1, "#808080")
    end

    properties
        % VALUE Pass/fail value.
        Value (1, 1) double
        % COLOR Pass/fail color.
        Color (1, 1) string
    end

    methods

        function this = Status(value, color)

            this.Value = value;
            this.Color = color;
        end

        function sortedThis = sort(this, varargin)

            [~, idxSort] = sort([this.Value], varargin{:});
            sortedThis = this(idxSort);
        end

        function value = getWorst(this)

            arguments
                this (1, :) mag.health.Status
            end

            locInclude = [this.Value] >= 0;
            these = this(locInclude);

            [~, idxMin] = min([these.Value]);
            value = these(idxMin);
        end

        function color = getThemedColor(this, figure)

            arguments
                this (1, 1) mag.health.Status
                figure (1, 1) matlab.ui.Figure
            end

            color = this.Color;

            if mag.internal.isThemeable(figure) && isequal(figure.Theme.BaseColorStyle, "dark")
                color = fliplightness(color);
            end
        end

        function icon = getIcon(this)

            arguments
                this (1, 1) mag.health.Status
            end

            switch this
                case mag.health.Status.Pass
                    icon = "success";
                case mag.health.Status.Fail
                    icon = "error";
                case mag.health.Status.Borderline
                    icon = "warning";
                case mag.health.Status.Incomplete
                    icon = "question";
            end
        end
    end
end
