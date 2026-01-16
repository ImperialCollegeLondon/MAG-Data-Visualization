# Copilot instructions for MAG Data Visualization

Purpose
- Help AI coding agents be productive in this MATLAB toolbox repository (R2024a+).

Big picture (quick):
- UI/entrypoint: [app/DataVisualization.m](app/DataVisualization.m) — orchestrates Mission `Provider`s and `Manager`s.
- Mission providers: `src/mission/*` packages (e.g. `+mag/+imap`, `+mag/+bart`) — implement `getModel()`, `getAnalysisManager()`, etc.
- Analysis core: [src/analyze/+mag/Analysis.m](src/analyze/+mag/Analysis.m) — abstract API: `detect`, `load`, `export`, and static `start()`.
- Data model: [src/data/+mag/Data.m](src/data/+mag/Data.m) — uses `mag.meta` metadata and `mag.mixin` helpers.
- Build & CI: [buildfile.m](buildfile.m) — defines `check`, `test`, `package` tasks; CI writes artifacts under `artifacts/`.

Key development workflows
- Install for development: run `mpminstall(pwd(), Authoring = true);` (see README).
- Run unit/system tests locally: use MATLAB's test runner, e.g. `runtests('tests')` or run the TestTask in `buildfile.m` via the MATLAB build tool in CI.
- Code checks and SARIF: `buildfile.m` configures a `CodeIssuesTask` that emits `artifacts/issues.sarif`.

Project-specific conventions and patterns
- MATLAB package-based namespace: code lives under `+mag` folders (e.g. `src/data/+mag`, `src/analyze/+mag`). Preserve package structure when moving files.
- Providers & Managers pattern: a Mission `Provider` returns a `Model` and `*Manager` instances. Managers subscribe to `Model` via `manager.subscribe(model)` and listen for `ModelChanged` events — mirror this when adding features.
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
   - `Instrument.m` — extend `mag.Instrument`, add sensor-specific dependent properties (e.g. `FOB`, `FIB`)
   - `+in/` — I/O format classes extending `mag.io.in.Format` with `Extension`, `load()`, `process()` methods
   - `+view/` — visualization classes (e.g. `Field.m`, `Spectrogram.m`) extending `mag.graphics.view.View`
2. **App files** under `app/mission/<name>/+mag/+app/+<name>/`:
   - `Provider.m` — extend `mag.app.Provider`, return Model and Managers
   - `Model.m` — extend `mag.app.Model`, implement `analyze`, `export`, `reset`
   - `AnalysisManager.m`, `ResultsManager.m`, `ExportManager.m`, `VisualizationManager.m`
3. **Register mission**:
   - Add enum value to `src/data/+mag/+meta/Mission.m` (if not already present)
   - Add case to switch statement in `app/DataVisualization.m` `selectMission()` method
4. **Conventions**:
   - Use inherited `Processing.ScienceSteps` for science processing instead of custom properties
   - Set metadata via `mag.meta.Science(Sensor, Mode, DataFrequency, Timestamp)` in I/O `process()` method
   - View figure titles should include Mode and frequency from metadata (e.g. `"Normal (FOB 16 Hz, FIB 16 Hz)"`)

Examples to reference
- Manager subscription pattern: see how managers are created and subscribed in [app/DataVisualization.m](app/DataVisualization.m).
- Abstract Analysis contract: see [src/analyze/+mag/Analysis.m](src/analyze/+mag/Analysis.m).
- Data model behaviors: see `get()` customization in [src/data/+mag/Data.m](src/data/+mag/Data.m).

Notes for AI code edits
- Avoid changing public API signatures for `Provider`, `Model`, `Analysis` and `Data` unless absolutely necessary; breakage is easily introduced across missions.
- Prefer small, focused edits with accompanying tests. Update `resources/release-notes.md` and `resources/mpackage.json` when changing public behavior or bumping versions.

If anything here is unclear or you want more detail (examples of tests to add, or typical CI commands), tell me which area to expand.
