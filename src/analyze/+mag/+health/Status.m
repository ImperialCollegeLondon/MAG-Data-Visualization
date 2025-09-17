classdef Status
% STATUS Health check status.

    enumeration
        % PASS Health check passed.
        Pass (1, "#14b814")
        % FAIL Health check failed.
        Fail (0, "#b50e0e")
        % BORDERLINE Health check provisionally passed.
        Borderline (0.5, "#d99e14")
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

        function value = getWorst(this)

            arguments
                this (1, :) mag.health.Status
            end

            [~, idxMin] = min([this.Value]);
            value = this(idxMin);
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
    end
end
