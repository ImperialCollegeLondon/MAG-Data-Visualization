classdef (Abstract) Control < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CONTROL Abstract base class for view-controllers.

    properties (Constant, Access = private)
        % DEFAULTSIZE Default grid layout size.
        DefaultSize (1, 2) double = [5, 3]
        % DEFAULTCOLUMNWIDTH Default column width.
        DefaultColumnWidth (1, 3) string = ["fit", "1x", "1x"]
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

        % VISUALIZE Plot all figures.
        figures = visualize(this, results)
    end

    methods (Access = protected)

        function layout = createDefaultGridLayout(this)
            layout = uigridlayout(this.Parent, this.DefaultSize, ColumnWidth = this.DefaultColumnWidth);
        end
    end

    methods (Static, Access = protected)

        function results = cropResults(results, startTime, endTime)

            arguments
                results (1, 1) mag.Instrument 
                startTime (1, 1) datetime
                endTime (1, 1) datetime
            end

            if ismissing(startTime)
                startTime = datetime("-Inf", TimeZone = "UTC");
            end

            if ismissing(endTime)
                endTime = datetime("Inf", TimeZone = "UTC");
            end

            period = timerange(startTime, endTime, "closed");

            results = results.copy();
            results.crop(period);
        end
    end
end
