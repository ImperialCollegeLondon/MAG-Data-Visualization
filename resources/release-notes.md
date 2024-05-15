# Software

## Graphics

- Add separate figure in `mag.graphics.view.Frequency` to show field and spectrogram
- Add `FrequencyPoints` option to specify number of frequency steps in `mag.graphics.chart.Spectrogram`
- Allow specifying mode and range cycling patterns when plotting CPT figures (`mag.graphics.cptPlots`)
- Do not use events for range event plotting in `mag.graphics.view.Field`
- Do not reshape compute PSD in `mag.graphics.view.PSD`, if sizes do not match

## Spectrogram

- Add `mag.Spectrum` data class to capture spectrogram results
- Add `mag.transform.Spectrogram` for computing spectrograms for all different time and mode periods separately
- Rename `mag.computeSpectrogram` to `mag.spectrogram`
- Update `mag.spectrogram` as a wrapper of `mag.transform.Spectrogram`
- `mag.graphics.chart.Spectrogram` does not compute spectrogram, it just plots it
- `mag.graphics.view.Frequency` computes spectrogram with `mag.spectrogram`

## Other

- Add `mag.time.Constant.Eps` for consistent definition of `eps` in seconds
- Improve algorithm for correction of mode change event timestamp (only correct mode changes and increase search window)
- Detect mode changes from timestamp cadence, when no event data is available
- Improve algorithm for detecting mode and range cycling
- Allow cropping with `datetime` pair denoting start and end times
- Do not improve event time estimates for Config mode
- Do not crop events if endpoints do not include any data
