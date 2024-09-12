classdef (Abstract) Control < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CONTROL Abstract base class for view-controllers.

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

    properties (SetAccess = immutable)
        Parent (1, 1) matlab.ui.container.Panel
    end

    methods

        function this = Control(parent)
            this.Parent = parent;
        end
    end

    methods (Abstract)

        % INSTANTIATE Populate view-control elements.
        instantiate(this)

        % GETVISUALIZECOMMAND Retrieve command to plot all figures.
        command = getVisualizeCommand(this, results)
    end

    methods (Access = protected)

        function layout = createDefaultGridLayout(this)
            layout = uigridlayout(this.Parent, this.DefaultSize, ColumnWidth = this.DefaultColumnWidth);
        end
    end
end
