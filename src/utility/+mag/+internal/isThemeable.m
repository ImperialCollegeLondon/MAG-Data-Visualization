function value = isThemeable(figure)
% ISTHEMEABLE Determine whether figure is themeable (i.e., if setting
% dark/light mode is supported).
    
    arguments (Input)
        figure (1, 1) matlab.ui.Figure
    end

    arguments (Output)
        value (1, 1) logical
    end

    value = isprop(figure, "Theme") && isa(figure.Theme, "matlab.graphics.theme.GraphicsTheme");
end
