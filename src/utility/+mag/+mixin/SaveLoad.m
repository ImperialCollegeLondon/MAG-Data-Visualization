classdef (Abstract, HandleCompatible) SaveLoad
% SAVELOAD Interface adding support for customization of saving and loading
% to MAT files.

    properties (Constant, Transient)
        % VERSION Version number.
        Version (1, 1) string = mag.version()
    end

    properties (Hidden, SetAccess = private)
        % ORIGINALVERSION Original version for save/load compatibility.
        OriginalVersion (1, 1) string
    end

    methods (Hidden)

        function savedObject = saveobj(this)

            savedObject = this;
            savedObject.OriginalVersion = this.Version;
        end
    end
end