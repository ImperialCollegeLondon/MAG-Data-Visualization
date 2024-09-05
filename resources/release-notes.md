# App

## Fixes

- Add placeholders for CPT settings with dynamic defaults
- Disable "Save Figures" and "Close Figures" buttons after using "Close Figures"
- Fix issues with validation of CPT primary and secondary modes, and range patterns (`mag.app.control.CPT`)

## Refactoring

- Move `cropResults` definition from `mag.app.control.Control` to `mag.app.internal.cropResults`
- Redesign `mag.app.control.Filter/addFilterButtons` signature to be more flexible
