classdef (Abstract) UITestCase < matlab.uitest.TestCase & mag.test.mixin.RequireMinMATLABRelease
% UITESTCASE Base class for all MAG UI tests.

    properties (Constant)
        MinimumRelease = "R2024b"
    end
end
