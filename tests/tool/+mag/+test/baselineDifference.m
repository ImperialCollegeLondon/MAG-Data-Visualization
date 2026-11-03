function message = baselineDifference(actual, fileName, variableName)
% BASELINEDIFFERENCE Describe first difference between value and its
% baseline, as baseline comparison only reports that objects differ.

    arguments (Input)
        actual % anything
        fileName (1, 1) string {mustBeFile}
        variableName (1, 1) string
    end

    arguments (Output)
        message (1, 1) string
    end

    expected = load(fileName, variableName).(variableName);
    [equality, difference] = mag.test.isequalTraversal(actual, expected);

    if equality
        message = "No difference from baseline found in public properties.";
    else
        message = compose("First difference from baseline: %s.", difference);
    end
end
