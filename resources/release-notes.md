# All

- Refactor IMAP and HelioSwarm code, in separate folders: `src/mission/*` and `app/mission/*`

# App

- Add support for HelioSwarm analysis
- Refactor `mag.app.Control` to not accept parent as constructor input, but rather as `instantiate` argument
- Exporting analysis to "Workspace" now creates a copy, to prevent unwanted modifications of original

# Software

- Add support for HelioSwarm analysis with `mag.hs.Analysis`
- Rename `mag.IMAPAnalysis` as `mag.imap.Analysis` (many other IMAP-related classes moved and renamed)

# GitHub

- Run tests also with MATLAB R2024b
