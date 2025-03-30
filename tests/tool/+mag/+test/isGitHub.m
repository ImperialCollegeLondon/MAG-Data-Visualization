function value = isGitHub()
% ISGITHUB Return whether tests are running on GitHub.

    value = ~isempty(getenv("GITHUB_ACTIONS"));
end
