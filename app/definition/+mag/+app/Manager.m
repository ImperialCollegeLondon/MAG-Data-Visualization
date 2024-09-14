classdef (Abstract) Manager < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% MANAGER Manager of app components.

    methods (Abstract)

        % INSTANTIATE Populate view-control elements.
        instantiate(this, parent)

        % RESET Reset to default values.
        reset(this)

        % SUBSCRIBE Subscribe to event.
        subscribe(this, model)
    end
end
