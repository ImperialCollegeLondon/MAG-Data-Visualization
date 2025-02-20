function varargout = visualize(varargin, options)
% VISUALIZE Plot data with specified styles and options.

    arguments (Input, Repeating)
        varargin
    end

    arguments (Input)
        options.?mag.graphics.factory.Settings
    end

    args = namedargs2cell(options);

    try
        [varargout{1:nargout}] = mag.graphics.factory.DefaultFactory().assemble(varargin{:}, args{:});
    catch exception
        rethrow(exception);
    end
end
