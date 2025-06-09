function mustBeColor(color)
% MUSTBECOLOR Verify that input value represents a color.

    if isempty(color) || (isa(color, "numeric") && (width(color) == 3))
        return;
    elseif isa(color, "numeric")

        exception = MException("", "Invalid format for ""Colors"" property.");
        exception.throwAsCaller();
    else

        mustBeTextScalar(color);
        mustBeNonzeroLengthText(color);
    end
end
