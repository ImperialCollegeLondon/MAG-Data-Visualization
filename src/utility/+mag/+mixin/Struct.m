classdef (Abstract, HandleCompatible) Struct
% STRUCT Interface adding support for converting to struct.

    methods (Hidden, Sealed)

        function structThis = struct(this)
        % STRUCT Convert class to struct containing only public properties.

            arguments (Input)
                this mag.mixin.Struct {mustBeScalarOrEmpty}
            end

            arguments (Output)
                structThis struct {mustBeScalarOrEmpty}
            end

            if isempty(this)

                structThis = struct.empty();
                return;
            end

            metaClasses = metaclass(this);

            for mc = metaClasses

                metaProperties = mc.PropertyList;
                metaProperties = metaProperties(~[metaProperties.Constant] & ({metaProperties.GetAccess} == "public") & ({metaProperties.SetAccess} == "public"));

                for mp = metaProperties'

                    n = mp.Name;
                    v = this.(n);

                    if isa(v, "mag.mixin.Struct")
                        structThis.(n) = struct(v);
                    elseif isenum(v)
                        structThis.(n) = string(v);
                    else
                        structThis.(n) = v;
                    end
                end

                metaClasses = [metaClasses, mc.SuperclassList']; %#ok<AGROW>
            end
        end
    end
end
