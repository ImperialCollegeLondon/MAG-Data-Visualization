classdef (Sealed) HelioSwarmAnalysis < matlab.mixin.Copyable & mag.mixin.SetGet & mag.mixin.SaveLoad
% HELIOSWARMANALYSIS Automate analysis of HelioSwarm data.

    properties (Constant)
        Version = mag.version()
    end

    properties
        % LOCATION Location of data to load.
        Location (1, 1) string {mustBeFolder} = pwd()
        % SCIENCEPATTERN Pattern of science data files.
        SciencePattern (1, :) string = fullfile("MAGScience-*-(*)-*.csv")
        % HKPATTERN Pattern of housekeeping files.
        HKPattern (1, 1) string = ""
        % PERFILEPROCESSING Steps needed to process single files of data.
        PerFileProcessing (1, :) mag.process.Step = [ ...
            mag.process.AllZero(Variables = ["time", "x", "y", "z"])]
        % WHOLEDATAPROCESSING Steps needed to process all of imported data.
        WholeDataProcessing (1, :) mag.process.Step = [ ...
            mag.process.Sort(), ...
            mag.process.Duplicates()]
        % SCIENCEPROCESSING Steps needed to process only strictly science
        % data.
        ScienceProcessing (1, :) mag.process.Step = []
        % HKPROCESSING Steps needed to process imported HK data.
        HKProcessing (1, :) mag.process.Step = []
    end


end
