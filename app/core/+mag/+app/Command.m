classdef Command < mag.mixin.SetGet
% COMMAND Class to capture command and its arguments.

    properties
        % FUNCTIONAL Function or class to be called.
        Functional (1, 1) function_handle = @disp
        % POSITIONALARGUMENTS Positional arguments to supply to functional.
        PositionalArguments cell
        % NAMEDALARGUMENTS Name-value pairs to supply to functional.
        NamedArguments struct {mustBeScalarOrEmpty}
    end

    properties (Dependent, SetAccess = private)
        % NARGIN Number of input arguments.
        NArgIn (1, 1) double
        % NARGOUT Number of output arguments.
        NArgOut (1, 1) double
    end

    methods

        function this = Command(options)

            arguments
                options.?mag.app.Command
            end

            this.assignProperties(options);
        end

        function value = get.NArgIn(this)
            value = nargin(this.Functional);
        end

        function value = get.NArgOut(this)
            value = nargout(this.Functional);
        end

        function args = getCellArguments(this)
        % GETCELLARGUMENTS Get arguments as cell array.

            if isempty(this.NamedArguments)
                args = {};
            else
                args = namedargs2cell(this.NamedArguments);
            end

            args = [this.PositionalArguments, args];
        end

        function varargout = call(this)
        % CALL Call functional with arguments.

            args = this.getCellArguments();
            [varargout{1:nargout}] = this.Functional(args{:});
        end
    end
end
