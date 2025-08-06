classdef Processing < mag.mixin.SetGet
% PROCESSING Capture processing steps for each phase.

    properties
        % PERFILESTEPS Steps needed to process single files of data.
        PerFileSteps (1, :) mag.process.Step
        % WHOLEDATASTEPS Steps needed to process all of imported data.
        WholeDataSteps (1, :) mag.process.Step
        % SCIENCESTEPS Steps needed to process only strictly science
        % data.
        ScienceSteps (1, :) mag.process.Step
        % HKSTEPS Steps needed to process imported HK data.
        HKSteps (1, :) mag.process.Step
    end
end
