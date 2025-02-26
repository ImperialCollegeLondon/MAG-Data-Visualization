classdef EventPSD < mag.graphics.view.View
% EVENTPSD Show PSD of magnetic field for each specified event.

    properties
        % NAME Figure name.
        Name string {mustBeScalarOrEmpty} = missing()
        % EVENT Event name to show.
        Event (1, 1) string {mustBeMember(Event, ["DataFrequency", "Range"])} = "DataFrequency"
    end

    methods

        function this = EventPSD(results, options)

            arguments
                results (1, 1) mag.imap.Instrument
                options.?mag.imap.view.EventPSD
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            primaryData = this.computeEventBasedPSD(this.Results.Primary);
            secondaryData = this.computeEventBasedPSD(this.Results.Secondary);

            if numel(primaryData) == numel(secondaryData)

                charts = cell(2, numel(primaryData));
                charts(:, 1:2:end) = reshape(primaryData, 2, []);
                charts(:, 2:2:end) = reshape(secondaryData, 2, []);
            else
                charts = [primaryData, secondaryData];
            end

            this.Figures = this.Factory.assemble( ...
                charts{:}, ...
                Name = this.getFigureName(), ...
                LinkXAxes = false, ...
                WindowState = "maximized");
        end
    end

    methods (Access = private)

        function charts = computeEventBasedPSD(this, data)

            charts = {};
            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");

            events = data.Events;
            interestingEvents = events(ismember(events.(this.Event), unique(events.(this.Event))), :);

            for i = 1:size(interestingEvents, 1)

                % Find when event takes place.
                startTime = interestingEvents.Time(i);

                if i == size(interestingEvents, 1)
                    endTime = data.Time(end);
                else
                    endTime = interestingEvents.Time(i + 1);
                end

                % Remove 30 seconds to avoid spikes during transitions.
                if (endTime - startTime) > minutes(2)

                    startTime = startTime + seconds(30);
                    endTime = endTime - seconds(30);
                end

                duration = endTime - startTime;

                if (duration > 0) && (height(data.Data(timerange(startTime, startTime + duration, "closed"), :)) > 7)

                    % Compute PSD.
                    psd = mag.psd(data, Start = startTime, Duration = duration);

                    % Add plot.
                    charts = [charts, {psd, ...
                        mag.graphics.style.Default(Title = this.getFigureTitle(data.Metadata, interestingEvents.Label(i), startTime, duration), ...
                        XLabel = this.FLabel, YLabel = this.PSDLabel, XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                        Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine])}]; %#ok<AGROW>
                end
            end
        end

        function value = getFigureName(this)

            if ismissing(this.Name)
                value = compose("%s PSD Analysis", this.Event);
            else
                value = this.Name;
            end
        end
    end

    methods (Access = private)

        function value = getFigureTitle(this, metadata, label, startTime, duration)
            value = compose("%s %s (%s, %s)", metadata.getDisplay("Sensor"), label, this.date2str(startTime, "dd-MMM-yy HH:mm"), duration);
        end
    end
end
