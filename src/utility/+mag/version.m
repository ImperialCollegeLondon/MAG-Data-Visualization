function v = version()
% VERSION Get MAG software version, compliant with Semantic Versioning
% 2.0.0.

    arguments (Output)
        v (1, 1) string {mustBeVersion}
    end

    persistent ver;

    if isempty(ver)

        location = fileparts(mfilename("fullpath"));
        root = fullfile(location, "../../../");

        package = matlab.mpm.Package(root);
        ver = package.Version;
    end

    v = ver;
end

function mustBeVersion(value)

    if ~matches(value, regexpPattern("\d+\.\d+\.\d+"))
        error("Version must be compliant with Semantic Versioning 2.0.0.");
    end
end
