classdef RampMode < mag.graphics.view.View
% RAMPMODE Show ramp mode.

    methods

        function this = RampMode(results, options)

            arguments
                results (1, 1) mag.imap.Instrument
                options.?mag.imap.view.RampMode
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            [primarySensor, secondarySensor] = this.getSensorNames();

            % Show full ramp.
            primary = this.Results.Primary;
            secondary = this.Results.Secondary;

            this.Figures(1) = this.Factory.assemble( ...
                primary, mag.graphics.style.Stackedplot(Title = primarySensor, YLabels = ["x [-]", "y [-]", "z [-]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z"])), ...
                secondary, mag.graphics.style.Stackedplot(Title = secondarySensor, YLabels = ["x [-]", "y [-]", "z [-]"], YAxisLocation = "right", Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z"])), ...
                Name = "Ramp Mode", ...
                LinkXAxes = false, ...
                WindowState = "maximized");

            % Show partial ramp derivative.
            rampSampleOffset = seconds(5);
            rampSampleDuration = seconds(0.25);

            primarySample = primary.copy();
            secondarySample = secondary.copy();

            primarySample.crop(timerange(primarySample.Time(1) + rampSampleOffset, primarySample.Time(1) + rampSampleOffset + rampSampleDuration));
            secondarySample.crop(timerange(secondarySample.Time(1) + rampSampleOffset, secondarySample.Time(1) + rampSampleOffset + rampSampleDuration));

            this.Figures(2) = this.Factory.assemble( ...
                primarySample, mag.graphics.style.Stackedplot(Title = primarySensor, YLabels = ["dx [-]", "dy [-]", "dz [-]"], Charts = mag.graphics.chart.Stackedplot(YVariables = ["dX", "dY", "dZ"], Marker = "o")), ...
                secondarySample, mag.graphics.style.Stackedplot(Title = secondarySensor, YLabels = ["dx [-]", "dy [-]", "dz [-]"], YAxisLocation = "right", Charts = mag.graphics.chart.Stackedplot(YVariables = ["dX", "dY", "dZ"], Marker = "o")), ...
                Title = compose("Sample %s", rampSampleDuration), ...
                Name = "Ramp Mode (Derivative)", ...
                LinkXAxes = false, ...
                WindowState = "maximized");
        end
    end
end
