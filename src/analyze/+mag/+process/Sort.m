classdef Sort < mag.process.Step
% SORT Sort data cronologically.

    properties
        % VARIABLES Variables to sort by.
        Variables (1, :) string = string.empty()
        % DIRECTION Sort direction.
        Direction (1, 1) string {mustBeMember(Direction, ["ascend", "descend"])} = "ascend"
    end

    methods

        function this = Sort(options)

            arguments
                options.?mag.process.Sort
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            arguments
                this
                data tabular
                ~
            end

            if isempty(this.Variables)
                data = sortrows(data, data.Properties.DimensionNames{1}, this.Direction);
            else
                data = sortrows(data, this.Variables, this.Direction);
            end
        end
    end
end
