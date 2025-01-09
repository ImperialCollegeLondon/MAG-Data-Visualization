# App

- Add checkbox in IMAP AT/SFT visualization options to show spectrograms
- Reduce duplication in definition of supported view-controllers for each mission

# Software

- Add `isPlottable` method to check if `mag.TimeSeries` has enough data to be plotted
- Fix issue with timed events (e.g., timed Burst mode) followed up by non-mode events (e.g., range-change events)
