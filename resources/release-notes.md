> [!WARNING]  
> Starting v7.2.0, MATLAB R2023b is no longer supported.

## Software

- Remove unnecessary `fullfile`s in `mag.imap.Analysis` default values

## CI

- Separate CI tests and packaging into separate GitHub workflows
- `main` branch is no longer "special" and is not packaged up on push
- Tags can be used to create new releases
