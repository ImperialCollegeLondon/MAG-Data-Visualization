classdef ErrorData < event.EventData
% ERRORDATA Event published on caught event.

    properties
        Exception MException {mustBeScalarOrEmpty}
    end

    methods

        function this = ErrorData(exception)
            this.Exception = exception;
        end
    end
end
