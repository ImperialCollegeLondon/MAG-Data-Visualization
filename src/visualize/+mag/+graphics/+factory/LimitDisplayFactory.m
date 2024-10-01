classdef LimitDisplayFactory < mag.graphics.factory.Factory
% LIMITDISPLAYFACTORY Factory to limit the number of data points displayed.

    properties
        % INNERFACTORY Inner factory to use for visualization.
        InnerFactory (1, 1) mag.graphics.factory.Factory = mag.graphics.factory.DefaultFactory()
        % DISPLAYLIMIT Maximum number of data points to display.
        DisplayLimit (1, 1) double = 1e5
    end

    methods

        function this = LimitDisplayFactory(options)

            arguments
                options.?mag.graphics.factory.LimitDisplayFactory
            end

            this.assignProperties(options);
        end

        function f = assemble(this, varargin)

            arguments (Input)
                this (1, 1) mag.graphics.factory.LimitDisplayFactory
            end

            arguments (Input, Repeating)
                varargin
            end

            arguments (Output)
                f (1, 1) matlab.ui.Figure
            end

            % Use inner factory to create figure.
            f = this.InnerFactory.assemble(varargin{:});

            % Add manager to control how figure behaves on pan, zoom and
            % rotation.
            for interaction = {pan(f), zoom(f), rotate3d(f)}
                interaction{1}.ActionPostCallback = @this.interactionCallback; %#ok<FXSET>
            end

            % Remove "restore view" toolbar button, as not compatible with
            % the above interactions.
            axes = findall(f, Type = "Axes");

            for ax = axes

                ax.BusyAction = "cancel";
                axtoolbar(ax, ["datacursor", "pan", "zoomin", "zoomout"]);
            end

            % Force trigger callbacks once.
            zoom(f, 1);
        end
    end

    methods (Access = private)

        function interactionCallback(this, figure, event)

            graphics = findall(figure, Type = "Line");

            for g = graphics(:)'

                if isempty(g.UserData)
                    g.UserData = struct(x = g.XData, y = g.YData);
                end

                ax = event.Axes;
                this.decimateToMatchLimits(g, ax.XLim, ax.YLim);
            end
        end
    end

    methods (Hidden, Access = private)

        function decimateToMatchLimits(this, g, xLim, yLim)

            x = g.UserData.x;
            y = g.UserData.y;

            % Find the data within the current axes limits.
            locLimits = x >= xLim(1) & x <= xLim(2) & y >= yLim(1) & y <= yLim(2);

            % Make sure the data just out of bounds of the current view
            % is also displayed, to avoid the line starting from within
            % the current view.
            locLimits = locLimits | circshift(locLimits, 1) | circshift(locLimits, -1);

            % Make sure first and last point are always present, to
            % avoid lines being "forgotten", if out of current view.
            [~, idxXMax] = max(x, [], "omitmissing");
            [~, idxXMin] = min(x, [], "omitmissing");

            locLimits([idxXMax, idxXMin]) = true;

            % Similarly, make sure min and max values are always present,
            % to avoid lines being "forgotten", if out of current view.
            [~, idxYMax] = max(y, [], "omitmissing");
            [~, idxYMin] = min(y, [], "omitmissing");

            locLimits([idxYMax, idxYMin]) = true;

            % Decimate the data to match the limit.
            xView = x(locLimits);
            yView = y(locLimits);

            N = numel(xView);

            if N > this.DisplayLimit

                decimationFactor = ceil(N / this.DisplayLimit);

                xView_ = xView(2:decimationFactor:end-1);
                yView_ = yView(2:decimationFactor:end-1);

                xView = [xView(1), xView_, xView(end)];
                yView = [yView(1), yView_, yView(end)];
            end

            % Update graph with reduced set of data.
            g.XData = xView;
            g.YData = yView;
        end
    end
end
