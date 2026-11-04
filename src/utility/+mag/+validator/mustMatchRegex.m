function mustMatchRegex(value, pattern)
% MUSTMATCHREGEX Validator to check value matches regex pattern.

    if ~isempty(value) && ~matches(value, regexpPattern(pattern))
        error("mag:validator:NoRegexMatch", "Value ""%s"" does not match pattern ""%s"".", value, pattern);
    end
end
