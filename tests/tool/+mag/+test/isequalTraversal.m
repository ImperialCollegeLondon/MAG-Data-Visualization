function [equality, difference] = isequalTraversal(a, b, propertyName)
% ISEQUALTRAVERSAL Determine equality between "a" and "b" and find the
% first property or index that differs.

    arguments (Input)
        a % anything
        b % anything
        propertyName (1, 1) string = "top-level"
    end

    arguments (Output)
        equality (1, 1) logical
        difference string {mustBeScalarOrEmpty}
    end

    % Check class.
    if ~isequal(class(a), class(b))

        equality = false;
        difference = compose("class of '%s'", propertyName);
        return;
    end

    % Check size.
    if ~isequal(size(a), size(b))

        equality = false;
        difference = compose("size of '%s'", propertyName);
        return;
    end

    % Iterate over each element and its properties.
    if isa(a, "handle")
        [equality, difference] = handleTraversal(a, b, propertyName);
    else

        for i = 1:numel(a)

            if ~isequaln(a(i), b(i))

                equality = false;
                difference = compose("%s(%d)", propertyName, i);
                return;
            end
        end

        equality = true;
        difference = string.empty();
    end
end

function [equality, difference] = handleTraversal(a, b, propertyName)

    mc = metaclass(a);

    mp = mc.PropertyList;
    mp = mp(~[mp.Constant] & ({mp.GetAccess} == "public") & ({mp.SetAccess} == "public"));

    for i = 1:numel(a)

        if isequaln(a(i), b(i))
            continue; % short-circuit
        end

        for j = 1:numel(mp)

            n = mp(j).Name;

            if isequaln(a(i).(n), b(i).(n))
                continue; % short-circuit
            end

            [equality, difference] = mag.test.isequalTraversal(a(i).(n), b(i).(n), compose("%s(%d).%s", propertyName, i, n));
            return;
        end
    end

    equality = true;
    difference = string.empty();
end
