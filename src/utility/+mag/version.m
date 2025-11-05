function v = version()
% VERSION Get MAG software version, compliant with Semantic Versioning
% 2.0.0.

    arguments (Output)
        v (1, 1) string {mustBeVersion}
    end

    persistent ver;

    if isempty(ver)

        ver = mag.internal.getPackageDetails("Version");

        % Look for installed toolbox.
        if isempty(ver)

            addOnRoot = fullfile(fileparts(mfilename("fullpath")), "../../../");
            ver = mag.internal.getAddOnVersion(addOnRoot);
        end
    end

    v = ver;
end

function mustBeVersion(value)

    if ~isstring(value) || ~matches(value, regexpPattern("\d+\.\d+\.\d+"))
        error("Version must be compliant with Semantic Versioning 2.0.0.");
    end
end
