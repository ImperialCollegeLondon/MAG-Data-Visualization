## App

- (IMAP) Remove "CDF" export format, as it could not work
- Fix figure buttons being updated more than once after changing mission
- Show an alert when exporting to the workspace or a MAT file fails
- Only create the results folder when something is saved to it
- (HelioSwarm) Remove "Metadata pattern" setting, as metadata files were never loaded
- (Bartington) Remove "Gradiometer" setting, as it had no effect

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
- (IMAP) Fix crash in export, range cycling and mode cycling when the pattern occurs more than once, or ends with the last event
- (HelioSwarm) Remove "CDF" from accepted export formats, as it is not implemented
- (Bartington) Throw clear error on export, as no formats are implemented
- (HENON) Fix `export` failing with wrong error when options are specified
- (All) Fix event filter adding rows when an event is close to the end of the data
- (All) PSD and spectrogram views no longer share the same transformation
- (IMAP) Load event logs with many commands faster (2,000 commands in 9.6 s instead of 26.7 s)
- (IMAP) Fix finding mode change times in data whose time variable is not named "t"
- (IMAP) Add mode slicing methods (`getAllModes`, `getModeCycling`, `getRangeCycling`, `getFinalNormalMode`) to `mag.imap.Instrument`
- (IMAP) Remove `splitByTimeGap`, which crashed when data had no gap, and dropped data after the last gap
- (HelioSwarm) Remove `InputSource` and `MetadataPattern` options, which had no effect. Loading HelioSwarm analyses saved by earlier versions warns that `mag.hs.meta.InputSource` cannot be found
- (HelioSwarm) `detect` no longer decodes binary files, as `start` decodes them before detecting files
- (HelioSwarm) Apply whole data processing steps, which were defined but never used
- (HelioSwarm, Vigil) Do not export science or HK data that is empty after cropping
- (Bartington) Remove `Gradiometer` option, which had no effect
- (Bartington) Fix `mag.bart.Instrument` validating its options against `mag.imap.Instrument`
- (Bartington) Figure titles only show the frequency of sensors with data, instead of "NaN" for a sensor without data
- (All) Fix processing steps being shared by all analyses, so that steps set by one mission, such as Vigil, were used by others
- (All) Fix reading file names of an analysis before detecting files, for all missions except IMAP
- (All) Combined HK data keeps the class of the imported data, instead of assuming IMAP HK
- (All) Import large CSV files faster, by no longer reading whole files to check they contain data
- (All) Separate data at many time gaps, and correct long packet sequences, much faster
- (All) A CSV file with a header followed only by a blank line is treated as empty, for both line ending styles
- (All) Add identifiers to all errors and warnings

## Package

- MATLAB R2025a or later is now required
- Development now requires MATLAB R2026b or later, as package definition uses schema 1.2.0
- Restore add-on description
- Remove build tools and editor backup files from toolbox
