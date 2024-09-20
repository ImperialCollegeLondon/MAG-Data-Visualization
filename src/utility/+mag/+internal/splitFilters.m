function varargout = splitFilters(filters, expectedNumber)
% SPLITFILTERS Split filters by expected numbers.

%#ok<*AGROW>

    arguments
        filters (1, :) cell
        expectedNumber double {mustBeScalarOrEmpty}
    end

    actualNumber = numel(filters);

    if ~isequal(actualNumber, 1) && ~isequal(actualNumber, expectedNumber)
        throwAsCaller(MException("", "Number of time filters (%d) does not match expected number (%d).", actualNumber, expectedNumber));
    end

    if isscalar(filters)

        for i = 1:expectedNumber
            varargout{i} = filters{1};
        end
    else

        for i = 1:expectedNumber
            varargout{i} = filters{i};
        end
    end
end
