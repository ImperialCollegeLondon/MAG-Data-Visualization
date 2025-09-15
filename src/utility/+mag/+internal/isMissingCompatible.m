function tf = isMissingCompatible(x)
% ISMISSINGCOMPATIBLE Determine whether input object is compatible with
% "missing" type.

    tf = (isa(x, "single") | isa(x, "double") | isa(x, "duration") | isa(x, "calendarDuration") | isa(x, "datetime") | isa(x, "categorical") | isa(x, "string")) & ~isenum(x);
end
