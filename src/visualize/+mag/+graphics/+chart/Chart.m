classdef (Abstract) Chart < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% CHART Definition of visualization of MAG science and HK data.

    properties
        % XVARIABLE Name of variable plotted on x-axis. Default is time.
        XVariable string {mustBeScalarOrEmpty}
        % FILTER Filter x- and y-axis variables.
        Filter (:, 1) logical = logical.empty()
    end

    properties (Dependent)
        % YVARIABLES Name of variables plotted on y-axis.
        YVariables (1, :) {mustBeA(YVariables, ["string", "mag.graphics.operation.Action"])}
    end

    properties (GetAccess = protected, SetAccess = private)
        YVariables_ (1, :) mag.graphics.operation.Action
    end

    methods

        function yVariables = get.YVariables(this)
            yVariables = this.YVariables_;
        end

        function set.YVariables(this, yVariables)

            if isa(yVariables, "string")
                this.YVariables_ = mag.graphics.operation.Select(Variables = yVariables);
            else
                this.YVariables_ = yVariables;
            end
        end
    end

    methods (Abstract)

        % PLOT Plot data on the given graphics element.
        graph = plot(this, data, axes, layout)
    end

    methods (Access = protected)

        function xData = getXData(this, data)
        % GETXDATA Retrieve x-axis data, based on selected variable name.
        % If no name is provided, use independent variable.

            arguments
                this (1, 1) mag.graphics.chart.Chart
                data {mustBeA(data, ["mag.Data", "tabular"])}
            end

            if isempty(this.XVariable)

                if isa(data, "tabular")
                    xData = data.(data.Properties.DimensionNames{1});
                else
                    xData = data.IndependentVariable;
                end
            else
                xData = data.(this.XVariable);
            end

            xData = this.applyFilter(xData);
        end

        function yData = getYData(this, data)
        % GETYDATA Retrieve y-axis data, based on selected variable names.
        % If no name is provided, use dependent variables.

            arguments
                this (1, 1) mag.graphics.chart.Chart
                data {mustBeA(data, ["mag.Data", "tabular"])}
            end

            if isempty(this.YVariables)

                if isa(data, "tabular")
                    yData = data.(data.Properties.DimensionNames{2});
                else
                    yData = data.DependentVariables;
                end
            else
                yData = this.YVariables.applyAll(data);
            end

            yData = this.applyFilter(yData);
        end
    end

    methods (Access = private)

        function filteredData = applyFilter(this, data)
        % APPLYFILTER Filter data based on specified filter.

            % No filtering.
            if isempty(this.Filter)
                filteredData = data;

            % Same filtering for each y-axis variable.
            elseif height(this.Filter) == height(data)
                filteredData = data(this.Filter, :);

            % Otherwise, throw an error.
            else
                error("Mismatch between filter and x- or y-axis variables.");
            end
        end
    end
end
