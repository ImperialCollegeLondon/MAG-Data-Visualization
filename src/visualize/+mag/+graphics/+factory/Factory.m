classdef (Abstract) Factory < mag.mixin.SetGet
% FACTORY Interface for graphics generation factories.

    methods (Abstract)

        % ASSEMBLE Plot data with specified styles and options.
        f = assemble(this, data, style, options)
    end
end
