function stopIfException(identifier)
% STOPIFEXCEPTION Stop if exception is caught.

    dbstop("if", "error", identifier);
    dbstop("if", "caught error", identifier);
end
