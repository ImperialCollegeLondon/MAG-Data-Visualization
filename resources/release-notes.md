## App

- (IMAP) Remove "CDF" export format, as it could not work
- Fix figure buttons being updated more than once after changing mission

## Analysis

- (IMAP) Fix crash when exporting with a time window that excludes some modes, or all data
- (IMAP) Apply export time window to range cycling and ramp mode
- (IMAP) Fix export permanently cropping I-ALiRT data of analysis
- (IMAP) Fix crash when importing I-ALiRT data from folders with a date in their name
- (IMAP) Fix crash when importing L1b data from only one sensor
- (IMAP) Fix mode changes to higher cadence not being located
- (IMAP) Fix crash when first time step in mode change search window is unconventional
- (IMAP) Fix error message for invalid fields in JSON metadata
- (IMAP) `Processing` option of `mag.imap.Analysis.start` is no longer ignored
- (IMAP) Clear ramp mode data when reloading analysis
- (IMAP) Warn and do not split data by mode when sensors have a different number of modes, instead of crashing or mislabeling data
- (IMAP) Fix crash when ramp mode is the last event, or ends with the data
- (HelioSwarm) Remove "CDF" from accepted export formats, as it is not implemented
- (Bartington) Throw clear error on export, as no formats are implemented
- (HENON) Fix `export` failing with wrong error when options are specified
- (All) Fix event filter adding rows when an event is close to the end of the data
- (All) PSD and spectrogram views no longer share the same transformation
