classdef Instrument < mag.meta.Data
% INSTRUMENT Description of MAG instrument data.

    properties
        % MISSION Name of mission.
        Mission mag.meta.Mission {mustBeScalarOrEmpty}
        % MODEL Instrument model type.
        Model string {mustBeScalarOrEmpty, mustBeMember(Model, ["LM", "EM", "FM"])}
        % BSW Boot sowftware version.
        BSW string {mustBeScalarOrEmpty}
        % ASW App software version.
        ASW string {mustBeScalarOrEmpty}
        % GSE GSE software version.
        GSE string {mustBeScalarOrEmpty}
        % OPERATOR Operator running experiment.
        Operator string {mustBeScalarOrEmpty}
        % ATTEMPTS Number of attempts to start FOB and FIB.
        Attemps (1, 2) double = NaN(1, 2)
    end

    methods

        function this = Instrument(options)

            arguments
                options.?mag.meta.Instrument
            end

            this.assignProperties(options);
        end
    end
end
