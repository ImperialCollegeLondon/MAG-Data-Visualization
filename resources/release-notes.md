# Software

- Add separate figure in `mag.graphics.view.Frequency` to show field and spectrogram
- Add `mag.time.Constant.Eps` for consistent definition of `eps` in seconds
- Add `FrequencyPoints` option to specify number of frequency steps in `mag.graphics.chart.Spectrogram`
- Improve algorithm for correction of mode change event timestamp (only correct mode changes and increase search window)
- Detect mode changes from timestamp cadence, when no event data is available
- Improve algorithm for detecting mode and range cycling
- Rename `mag.computeSpectrogram` to `mag.spectrogram`
- Update `mag.spectrogram` to compute spectrogram for all different time periods separately
- Allow cropping with `datetime` pair denoting start and end times
- Do not improve event time estimates for Config mode
