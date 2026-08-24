classdef HK < mag.graphics.view.View
% HK Show housekeeping for HelioSwarm.

    properties
        % SELECTEDFIELDS HK fields to plot as separate figures.
        SelectedFields (1, :) string = string.empty()
    end

    properties (Constant, Access = private)
        GainFields (1, 3) string = ["x_gain", "y_gain", "z_gain"]
    end

    methods

        function this = HK(results, options)

            arguments
                results
                options.?mag.hs.view.HK
            end

            this.Results = results;

            this.assignProperties(options);
        end

        function visualize(this)

            this.Figures = matlab.ui.Figure.empty();

            hk = this.Results.HK;

            if isempty(hk)
                return;
            end

            hk = hk(1);
            availableFields = string(hk.Data.Properties.VariableNames);

            selectedFields = this.SelectedFields(ismember(this.SelectedFields, availableFields));

            if isempty(selectedFields)
                return;
            end

            for field = selectedFields

                this.Figures(end + 1) = this.plotField( ...
                    hk.Data, field, field, compose("HK %s", field)); %#ok<AGROW>

                if ismember(field, this.GainFields)

                    if ~ismember("range", availableFields)
                        warning("mag:hs:HK:MissingRange", ...
                            "Cannot calibrate ""%s"" because HK data does not contain ""range"".", field);
                        continue;
                    end

                    gainData = hk.Data(:, field);
                    rawGains = gainData.(field);
                    ranges = double(hk.Data.range);

                    gainData.(field) = mag.hs.view.HK.checkGainRange(rawGains, ranges);

                    calibratedTitle = field + " calibrated";

                    this.Figures(end + 1) = this.plotField( ...
                        gainData, field, calibratedTitle, compose("HK %s calibrated", field)); %#ok<AGROW>
                end
            end
        end
    end

    methods (Access = private)

        function figureHandle = plotField(this, data, yVariable, titleText, figureName)

            figureHandle = this.Factory.assemble( ...
                data, ...
                mag.graphics.style.Default(Title = titleText, XLabel = "Time", YLabel = yVariable, Charts = mag.graphics.chart.Plot(YVariables = yVariable)), ...
                Name = figureName, ...
                WindowState = "maximized");

            axesHandle = findall(figureHandle, Type = "axes");
            ylabel(axesHandle, yVariable, Interpreter = "none");
            title(axesHandle, titleText, Interpreter = "none");
        end
    end

    methods (Static)

        function calibratedGains = checkGainRange(rawGains, ranges)

            offsets = [0, 4, 6, 8];
            offsetVector = offsets(ranges + 1);
            calibratedGains = rawGains - offsetVector';
        end
    end
end
