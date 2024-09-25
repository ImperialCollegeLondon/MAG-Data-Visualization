classdef tSaveLoad < matlab.mock.TestCase
% TSAVELOAD Unit tests for "mag.mixin.SaveLoad" class.

    methods (Test)

        % Test that "saveobj" method assigns the "OriginalVersion" value.
        function saveobj(testCase)

            % Set up.
            saveLoad = testCase.createMock(?mag.mixin.SaveLoad, Strict = true);

            % Exercise.
            savedObject = saveobj(saveLoad);

            % Verify.
            testCase.verifyEqual(savedObject.OriginalVersion, savedObject.Version, """OriginalVersion"" should match expectation.");
        end
    end
end
