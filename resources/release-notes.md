# All

- Refactor IMAP and HelioSwarm code, in separate folders: `src/mission/*` and `app/mission/*`

# App

- Add support for HelioSwarm analysis
- Refactor app to use MVVM design
- Do not show warning stack trace for any long-running function
- Show success message upon successful import
- Exporting analysis to "Workspace" now creates a copy, to prevent unwanted modifications of original
- Delete App Designer app

# Software

- Add abstract base class for generic analysis `mag.Analysis`
- Add support for HelioSwarm analysis with `mag.hs.Analysis` (add many other HelioSwarm-related classes for import/export, visualization, etc.)
- Rename `mag.IMAPAnalysis` as `mag.imap.Analysis` (many other IMAP-related classes moved and renamed)
- Add new definition of `mag.imap.Instrument` for specific IMAP results (e.g., including I-ALiRT)
- Convert `mag.Science/computePSD` to transformation `mag.transform.PSD` and convenience function `mag.psd`

# GitHub

- Run tests also with MATLAB R2024b
- Add release to "Test Results" and "Coverage Report" in CI results
- Use `.env` file to define version (also in `mag.version`)
