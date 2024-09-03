classdef (Abstract) Control < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CONTROL Abstract base class for view-controllers.

    properties (SetAccess = immutable)
        % PARENT Parent of view-controller.
        Parent (1, 1) matlab.ui.container.Panel
        % RESULTS Results to plot.
        Results (1, 1) mag.Instrument
    end

    methods

        function this = Control(parent, results)

            this.Parent = parent;
            this.Results = results;
        end
    end

    methods (Abstract)

        % INSTANTIATE Populate view-control elements.
        instantiate(this)

        % VISUALIZE Plot all figures.
        figures = visualize(this)
    end

    methods (Access = protected)

        function results = cropResults(this, startTime, endTime)

            arguments
                this
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

            results = this.Results.copy();
            results.crop(period);
        end
    end
end
