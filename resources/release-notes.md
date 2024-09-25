# All

- Refactor IMAP and HelioSwarm code, in separate folders: `src/mission/*` and `app/mission/*`

# App

- Add support for HelioSwarm analysis
- Refactor app to use MVVM design
- Delete App Designer app
- Exporting analysis to "Workspace" now creates a copy, to prevent unwanted modifications of original

# Software

- Add abstract base class for generic analysis `mag.Analysis`
- Add support for HelioSwarm analysis with `mag.hs.Analysis`
- Rename `mag.IMAPAnalysis` as `mag.imap.Analysis` (many other IMAP-related classes moved and renamed)
- Add new definition of `mag.imap.Instrument` for specific IMAP results (e.g., including I-ALiRT)
- Convert `mag.Science/computePSD` as transformation `mag.transform.PSD` and convenience function `mag.psd`

# GitHub

- Run tests also with MATLAB R2024b
- Use `.env` file to define version (also in `mag.version`)
