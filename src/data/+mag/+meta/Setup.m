classdef Setup < mag.mixin.SetGet & mag.mixin.Struct
% SETUP Description of MAG sensor setup.

    properties
        % MODEL Sensor model type and number.
        Model string {mustBeScalarOrEmpty, mag.validator.mustMatchRegex(Model, "^\wM\d?$")}
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
    end
end
