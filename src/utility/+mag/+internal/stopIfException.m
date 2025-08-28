function stopIfException(identifier)
% STOPIFEXCEPTION Stop if exception is caught.

    arguments
        identifier string {mustBeScalarOrEmpty}
    end

    if isempty(identifier) || (strlength(identifier) == 0)
        identifier = {};
    else
        identifier = {identifier};
    end

    dbstop("if", "error", identifier{:});
    dbstop("if", "caught error", identifier{:});
end
