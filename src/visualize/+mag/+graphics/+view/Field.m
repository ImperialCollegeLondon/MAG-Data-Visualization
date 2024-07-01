classdef Field < mag.graphics.view.Science
% FIELD Show magnetic field and optional HK.

    properties
        % EVENT Event name to show.
        Event (1, :) string {mustBeMember(Event, ["Compression", "Mode", "Range"])} = string.empty()
    end

    methods

        function this = Field(results, options)

            arguments
                results
                options.?mag.graphics.view.Field
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();
            hk = this.getHKType("PW");

            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            [numEvents, eventData] = this.getEventData(primary, secondary, primarySensor, secondarySensor);

            if isempty(hk) || ~hk.HasData

                this.Figures = this.Factory.assemble( ...
                    primary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primary.Quality.isPlottable())), ...
                    secondary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = secondary.Quality.isPlottable())), ...
                    eventData{:}, ...
                    Title = this.getFigureTitle(primary, secondary), ...
                    Name = this.getFigureName(primary, secondary), ...
                    Arrangement = [3 + numEvents, 2], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            else

                this.Figures = this.Factory.assemble( ...
                    primary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(primary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = primary.Quality.isPlottable())), ...
                    secondary, mag.graphics.style.Stackedplot(Title = this.getFieldTitle(secondary), YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", Layout = [3, 1], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = secondary.Quality.isPlottable())), ...
                    eventData{:}, ...
                    hk, [mag.graphics.style.Default(Title = compose("%s & ICU Temperatures", primarySensor), YLabel = this.TLabel, Legend = [primarySensor, "ICU"], Charts = mag.graphics.chart.Plot(YVariables = [primarySensor, "ICU"] + "Temperature")), ...
                    mag.graphics.style.Default(Title = compose("%s & ICU Temperatures", secondarySensor), YLabel = this.TLabel, YAxisLocation = "right", Legend = [secondarySensor, "ICU"], Charts = mag.graphics.chart.Plot(YVariables = [secondarySensor, "ICU"] + "Temperature"))], ...
                    Title = this.getFigureTitle(primary, secondary), ...
                    Name = this.getFigureName(primary, secondary), ...
                    Arrangement = [4 + numEvents, 2], ...
                    LinkXAxes = true, ...
                    WindowState = "maximized");
            end
        end
    end

    methods (Access = private)

        function [numEvents, eventData] = getEventData(this, primary, secondary, primarySensor, secondarySensor)

            numEvents = 0;
            eventData = {};

            selectedEvents = this.Event;

            if isempty(selectedEvents) && (any(diff(primary.Compression) ~= 0) || any(diff(secondary.Compression) ~= 0))
                selectedEvents = "Compression";
            end

            for e = selectedEvents

                switch e
                    case "Compression"

                        numEvents = numEvents + 1;
                        ed = {primary, mag.graphics.style.Default(Title = compose("%s Compression", primarySensor), YLabel = "compressed [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Compression")), ...
                            secondary, mag.graphics.style.Default(Title = compose("%s Compression", secondarySensor), YLabel = "compressed [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Compression"))};

                    case "Mode"

                        numEvents = numEvents + 1;
                        ed = {primary.Events, mag.graphics.style.Default(Title = compose("%s Modes", primarySensor), YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = primary.Time(end))), ...
                            secondary.Events, mag.graphics.style.Default(Title = compose("%s Modes", secondarySensor), YLabel = "mode [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = secondary.Time(end)))};

                    case "Range"

                        numEvents = numEvents + 1;
                        ed = {primary, mag.graphics.style.Default(Title = compose("%s Ranges", primarySensor), YLabel = "range [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", IgnoreMissing = false, YOffset = 0.25)), ...
                            secondary, mag.graphics.style.Default(Title = compose("%s Ranges", secondarySensor), YLabel = "range [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", IgnoreMissing = false, YOffset = 0.25))};

                    otherwise
                        error("Unrecognized event ""%s"".", e);
                end

                eventData = [eventData, ed]; %#ok<AGROW>
            end
        end
    end
end
