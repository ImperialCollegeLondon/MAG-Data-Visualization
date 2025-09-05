classdef (Abstract) Manager < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% MANAGER Manager of app components.

    methods (Abstract)

        % INSTANTIATE Populate view-control elements.
        instantiate(this, parent)

        % RESET Reset to default values.
        reset(this)
    end

    methods

        % SUBSCRIBE Subscribe to event.
        function subscribe(this, model)
            model.addlistener("ModelChanged", @this.modelChangedCallback);
        end
    end

    methods (Abstract, Access = protected)

        % MODELCHANGEDCALLBACK Callback for model changed.
        modelChangedCallback(this, model, event)
    end
end
