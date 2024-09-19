# All

- Refactor IMAP and HelioSwarm code, in separate folders: `src/mission/*` and `app/mission/*`

# App

- Add support for HelioSwarm analysis
- Refactor app to use MVVM design
- Delete App Designer app
- Exporting analysis to "Workspace" now creates a copy, to prevent unwanted modifications of original

# Software

- Add support for HelioSwarm analysis with `mag.hs.Analysis`
- Rename `mag.IMAPAnalysis` as `mag.imap.Analysis` (many other IMAP-related classes moved and renamed)

# GitHub

- Run tests also with MATLAB R2024b
