function details = getPackageDetails(fieldName)
% GETPACKAGEDETAILS Load MATLAB package details from manifest.

    arguments (Input)
        fieldName string {mustBeScalarOrEmpty, mustBeNonzeroLengthText} = string.empty()
    end

    root = fullfile(fileparts(mfilename("fullpath")), "../../../../");
    details = readstruct(fullfile(root, "resources", "mpackage.json"));

    if ~isempty(fieldName)

        % If the first letter is capitalized (for compatibility with
        % "matlab.mpm.Package" properties), make it lowercase.
        fieldName = regexprep(fieldName, "(\w)(\w+)", "${lower($1)}$2");

        details = details.(fieldName);
    end
end
