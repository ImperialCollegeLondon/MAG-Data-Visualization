classdef Event < mag.graphics.chart.Event
% EVENT Custom chart for plotting IMAP events. Missing values are ramp
% mode.

    methods

        function this = Event(options)

            arguments
                options.?mag.imap.chart.Event
            end

            this.MissingLabel = "Ramp";
            this.assignProperties(options);
        end
    end
end
