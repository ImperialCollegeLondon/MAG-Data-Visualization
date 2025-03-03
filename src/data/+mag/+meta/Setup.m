classdef Setup < mag.mixin.SetGet & mag.mixin.Struct
% SETUP Description of MAG sensor setup.

    properties
        % MODEL Sensor model type and number.
        Model string {mustBeScalarOrEmpty}
        % FEE FEE id.
        FEE string {mustBeScalarOrEmpty, mag.validator.mustMatchRegex(FEE, "^FEE\d$")}
        % HARNESS Harness connecting sensor to electronics box.
        Harness string {mustBeScalarOrEmpty}
        % CAN Can containing sensor.
        Can string {mustBeScalarOrEmpty}
    end

    methods

        function this = Setup(options)

            arguments
                options.?mag.meta.Setup
            end

            this.assignProperties(options);
        end

        function value = string(this)

            value = string.empty();
            properties = ["Model", "FEE", "Can"];

            for p = properties

                if ~isempty(p)
                    value = [value, this.(p)]; %#ok<AGROW>
                end
            end

            value = join(value, " - ");
        end
    end
end
