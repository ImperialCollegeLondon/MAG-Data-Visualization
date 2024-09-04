# App

- Convert AppDesigner `DataVisualization` app to class
- Redesign "Visualize" tab to dynamically change plot options based on selected plot type
- Add individual figures to list of supported plot types
- Visualization options make now use of view-controllers (inherit from `mag.app.control.Control`)

# Software

- Rename `mag.graphics.view.PSD` to `mag.graphics.view.EventPSD`
- Split up `mag.graphics.view.Frequency` into:
    - `mag.graphics.view.Spectrogram` for just spectrogram
    - `mag.graphics.view.PSD` for just PSD
- Rename `Event` to `Events` in `mag.graphics.view.Field`

# README

- Link to Confluence documentation
