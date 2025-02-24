classdef Crop < mag.process.Step
% CROP Remove some data points at the beginning of file.

    properties
        % NUMBEROFVECTORS Number of vectors to crop at beginning.
        NumberOfVectors (1, 1) double
    end

    methods

        function this = Crop(options)

            arguments
                options.?mag.process.Crop
            end

            this.assignProperties(options);
        end

        function data = apply(this, data, ~)

            arguments
                this
                data tabular
                ~
            end

            data(1:this.NumberOfVectors, :) = [];
        end
    end
end
