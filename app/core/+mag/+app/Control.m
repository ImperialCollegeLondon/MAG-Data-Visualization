classdef (Abstract) Control < mag.app.manage.Manager
% CONTROL Abstract base class for view-controllers.

    properties (Abstract, Constant)
        % NAME View name.
        Name (1, 1) string
    end

    properties (Constant, Access = private)
        % DEFAULTSIZE Default grid layout size.
        DefaultSize (1, 2) double = [5, 3]
        % DEFAULTCOLUMNWIDTH Default column width.
        DefaultColumnWidth (1, 3) string = ["fit", "1x", "1x"]
    end

    properties (Constant, Access = protected)
        % DYNAMICPLACEHOLDER Placeholder text for dynamic defaults.
        DynamicPlaceholder (1, 1) string = "dynamic (default)"
    end

    methods (Abstract)

        % ISSUPPORTED Determine whether view-controller is supported.
        supported = isSupported(this, results)

        % GETVISUALIZECOMMAND Retrieve command to plot all figures.
        command = getVisualizeCommand(this, results)
    end

    methods

        function reset(~)
            error("Reset method not supported.");
        end
    end

    methods (Access = protected)

        function modelChangedCallback(~, ~, ~)
            % do nothing
        end

        function layout = createDefaultGridLayout(this, parent)
            layout = uigridlayout(parent, this.DefaultSize, ColumnWidth = this.DefaultColumnWidth);
        end
    end
end
