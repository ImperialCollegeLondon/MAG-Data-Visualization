classdef (Abstract) Provider < matlab.mixin.Heterogeneous & mag.mixin.SetGet
% PROVIDER Abstract base class for app components providers.

    methods (Abstract)

        % GETANALYSISMANAGER Retrieve analysis manager.
        manager = getAnalysisManager(this)
    end
end
