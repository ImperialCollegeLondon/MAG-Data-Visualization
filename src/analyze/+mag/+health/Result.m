classdef Result < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% RESULT Health check result.

    properties
        % STATUS Health check status.
        Status (1, 1) mag.health.Status
        % NAME Health check name.
        Name (1, 1) string
        % DESCRIPTION Description of health check results.
        Description (1, 1) string
    end

    methods

        function this = Result(options)

            arguments
                options.?mag.health.Result
            end

            this.assignProperties(options);
        end
    end

    methods (Sealed)

        function print(this)

            arguments
                this (1, :) mag.health.Result
            end

            fprintf("%s\n", "Health check results:");

            for result = this

                switch result.Status
                    case "Pass"
                        format = {"    %s: %s\n"};
                    case "Fail"
                        format = {2, "    %s: %s\n"};
                    case "Borderline"
                        format = {"    %s: [\b%s]\b\n"};
                end

                fprintf(format{:}, result.Name, result.Description);
            end
        end
    end
end
