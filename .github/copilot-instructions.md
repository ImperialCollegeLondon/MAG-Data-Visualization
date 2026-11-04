# Copilot instructions for MAG Data Visualization

Purpose
- Help AI coding agents be productive in this MATLAB toolbox repository (R2025a+ to use, R2026b to develop).

Big picture (quick):
- UI/entrypoint: [app/DataVisualization.m](app/DataVisualization.m) — orchestrates the `Provider` and `Manager`s of the selected mission.
- App provider: one [app/core/+mag/+app/Provider.m](app/core/+mag/+app/Provider.m) and one [app/core/+mag/+app/Model.m](app/core/+mag/+app/Model.m) serve all missions, driven by `mag.meta.Mission`. A mission customizes a manager by defining a class with the same name in its app namespace (e.g. `mag.app.imap.AnalysisManager`), and uses the shared manager in `app/core/+mag/+app/+manage` otherwise.
- Mission code: `src/mission/*` packages (e.g. `+mag/+imap`, `+mag/+bart`) — analysis, instrument, I/O formats and views of each mission.
- Analysis core: [src/analyze/+mag/Analysis.m](src/analyze/+mag/Analysis.m) — abstract API: `detect`, `load`, `export`, and static `start()`.
- Data model: [src/data/+mag/Data.m](src/data/+mag/Data.m) — uses `mag.meta` metadata and `mag.mixin` helpers.
- Build & CI: [buildfile.m](buildfile.m) — defines `check`, `test`, `package` tasks; CI writes artifacts under `artifacts/`.

Key development workflows
- Install for development: run `mpminstall(pwd(), Authoring = true);` (see README).
- Run unit/system tests locally: use MATLAB's test runner, e.g. `runtests('tests')` or run the TestTask in `buildfile.m` via the MATLAB build tool in CI.
- Code checks and SARIF: `buildfile.m` configures a `CodeIssuesTask` that emits `artifacts/issues.sarif`.

Project-specific conventions and patterns
- MATLAB package-based namespace: code lives under `+mag` folders (e.g. `src/data/+mag`, `src/analyze/+mag`). Preserve package structure when moving files.
- Providers & Managers pattern: `mag.app.Provider(mission)` returns a `Model` and `*Manager` instances. Managers subscribe to `Model` via `manager.subscribe(model)` and listen for `ModelChanged` events — mirror this when adding features.
- Abstract base contracts: extend provided abstract classes instead of reimplementing core behavior (e.g. subclass `mag.Analysis` and implement `detect/load/export`).
- Mixins & copy semantics: many domain objects use `mag.mixin.SetGet`, `SaveLoad`, and `matlab.mixin.Copyable`; follow these patterns for property access and copy behavior.
- Results and export semantics: the app composes results paths using `mag.version()` and `Results (v%s)`; exporting is centralized via `ExportManager` and `Model.export()` (see [app/DataVisualization.m](app/DataVisualization.m)).

Integration points & external deps
- External libs required: MATLAB SPICE (MICE) and MATLAB SPDF CDF — tests and data loaders rely on these (see README).
- Packaging: `resources/mpackage.json` and `resources/extensions.json` are used by the packaging task in `buildfile.m` (update them when bumping versions).

What to change and how to verify
- When adding a new `Analysis` or `Instrument` implementation:
  - Place code under the correct `+mag` package and mirror existing folder structure (see `src/mission/*`).
  - Implement the abstract API (`detect`, `load`, `export`) and add unit tests to `tests/unit` and integration tests to `tests/system`.
  - Run `runtests('tests')` locally and ensure new tests are included in the `TestTask` defined in `buildfile.m`.

Adding a new mission (checklist)
1. **Core files** under `src/mission/<name>/+mag/+<name>/`:
   - `Analysis.m` — extend `mag.Analysis`, implement `detect`, `load`, `export`, and static `start()`
   - `Instrument.m` — extend `mag.Instrument`, add sensor-specific dependent properties (e.g. `OBS`, `IBS`)
   - `+in/` — I/O format classes extending `mag.io.in.Format` with `Extension`, `load()`, `process()` methods
   - `+view/` — visualization classes (e.g. `Field.m`, `Spectrogram.m`) extending `mag.graphics.view.View`
   - `+out/` — export format classes (e.g. `ScienceMAT.m`) extending `mag.io.out.MAT` with `getExportFileName()`, `convertToExportFormat()` methods
2. **App files** under `app/mission/<name>/+mag/+app/+<name>/`:
   - `VisualizationManager.m` — required, as there is no shared one
   - `AnalysisManager.m`, `ResultsManager.m`, `ExportManager.m` — only if the shared managers in `app/core/+mag/+app/+manage` are not enough. The shared `AnalysisManager` shows location and science pattern; subclasses override `instantiateSettings`, `resetSettings` and `getSettingsOptions`
3. **Register mission**:
   - Add enum value to `src/data/+mag/+meta/Mission.m`, with its display name, short name and namespace name (e.g. `"vigil"` for `mag.vigil` and `mag.app.vigil`)
4. **Tests** under `tests/`:
   - `tests/system/analyze/t<Name>Analysis.m` — system tests for analysis workflow
   - `tests/system/app/t<Name>App.m` — app integration tests
   - `tests/unit/io/t<Name>*In.m` — unit tests for I/O input format
   - `tests/unit/data/t<Name>Instrument.m` — unit tests for Instrument class
   - Test data files in `tests/system/test_data/<name>/` and `tests/unit/io/test_data/`
5. **Conventions**:
   - Use inherited `Processing.ScienceSteps` for science processing instead of custom properties
   - Set metadata via `mag.meta.Science(Sensor, Mode, DataFrequency, Timestamp)` in I/O `process()` method
   - View figure titles should include Mode and frequency from metadata (e.g. `"Normal (Outboard 1 Hz, Inboard 1 Hz)"`)
   - Use descriptive property names like `Outboard`/`Inboard` rather than acronyms like `OBS`/`IBS` for public Instrument API
   - The underlying `mag.meta.Sensor` enum values (`OBS`, `IBS`) are used internally for sensor identification. The `FOB` and `FIB` enum values are hidden aliases kept for loading old data
   - `OBS`/`IBS` name the outboard and inboard sensors, while `FOB`/`FIB` name the front-end electronics (FEE) that process each sensor's data. They are not interchangeable: quantities measured on the electronics keep `FOB`/`FIB`, e.g. IMAP HK properties such as `FOBTemperature` and `FOBAttempts`, and their human-readable names such as "FOB Temperature"
   - Names that come from external data keep their original form, e.g. IMAP HK columns (`FOB_TEMP`) and export format struct field names (e.g. `B.FOB`, `B.FIB` in MAT files)
   - Give every `error` and `warning` an identifier of the form `mag:<area>:<Name>`, e.g. `mag:imap:UnequalModes`

I/O format implementation notes
- **Input formats** (`+in/`):
  - Extend `mag.io.in.Format`, set `Extension` property (e.g. `".log.txt"`)
  - Implement `load(fileName)` to read raw data into a timetable
  - Implement `process(rawData, fileName)` to create `mag.Science` with proper metadata
  - Extract timestamp from filename if not in data (use `regexp` with named tokens)
  - Calculate `DataFrequency` dynamically from timestamps: `round(1 / mode(seconds(diff(data.t))))`
- **Output formats** (`+out/`):
  - Extend `mag.io.out.MAT` for MAT export
  - Implement `getExportFileName(data)` returning filename with timestamp, mode, frequencies
  - Implement `convertToExportFormat(data)` returning struct with sensor data
  - Use `this.flattenStruct(metadata)` to convert metadata objects to flat structs
  - Handle cases where only one sensor has data

View implementation notes
- Extend `mag.graphics.view.View`, accept `mag.<mission>.Instrument` as `results` argument
- Access sensor data via `this.Results.Outboard` / `this.Results.Inboard`
- Check data availability before accessing: `if ~isempty(outboard) && outboard.HasData`
- Use `this.getDataFrequency(metadata)` helper to format frequency strings (e.g. `"Outboard 1 Hz"`)
- Build figure titles showing all available sensor info when both sensors present

Examples to reference
- Manager subscription pattern: see how managers are created and subscribed in [app/DataVisualization.m](app/DataVisualization.m).
- Abstract Analysis contract: see [src/analyze/+mag/Analysis.m](src/analyze/+mag/Analysis.m).
- Data model behaviors: see `get()` customization in [src/data/+mag/Data.m](src/data/+mag/Data.m).
- Vigil mission implementation: see `src/mission/vigil/` for a complete example of a simple mission with dual sensors.

Notes for AI code edits
- Avoid changing public API signatures for `Provider`, `Model`, `Analysis`, `Instrument` and `Data` unless absolutely necessary; breakage is easily introduced across missions.
- IMAP mode slicing (`getAllModes`, `getModeCycling`, `getRangeCycling`, `getFinalNormalMode`) lives in `mag.imap.Instrument`; `mag.imap.Analysis` only forwards to it.
- Prefer small, focused edits with accompanying tests. Update `resources/release-notes.md` and `resources/mpackage.json` when changing public behavior or bumping versions.

If anything here is unclear or you want more detail (examples of tests to add, or typical CI commands), tell me which area to expand.
