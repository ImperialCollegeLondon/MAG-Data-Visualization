# App

## Fixes

- Add placeholders for CPT settings with dynamic defaults
- Disable "Save Figures" and "Close Figures" buttons after using "Close Figures"
- Fix issues with validation of CPT primary and secondary modes, and range patterns (`mag.app.control.CPT`)
- Fix AppDesigner app `DataVisualization_AppDesigner.mlapp` class name

## Refactoring

- Move `cropResults` definition from `mag.app.control.Control` to `mag.app.internal.cropResults`
- Redesign `mag.app.control.StartEndDate/addStartEndDateButtons` signature to be more flexible
- Redesign `mag.app.control.Filter/addFilterButtons` signature to be more flexible

# Software

- Add support in `mag.Instrument/crop`, `mag.Science/select` and `mag.graphics.view.Field/visualize` for empty science

# Tests

- Add tests for `mag.app.control.Field` and `mag.app.control.Spectrogram`
- Add tests for `mag.app.internal.combineDateAndTime`

# Build

- Include coverage for `app` folder
