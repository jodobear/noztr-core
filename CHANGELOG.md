# Changelog

This changelog records intentional public release changes for `noztr`.

Current release posture:

- the RC-facing review is locally positive
- final RC closure is still pending downstream `nzdk` feedback
- the first intentional public release should start at `0.1.0`

For the public versioning policy, see
[docs/stability-and-versioning.md](docs/stability-and-versioning.md).

## [Unreleased]

### Added

- public docs surface under `docs/`
- public task and example routing
- public ownership, performance, compatibility, and versioning notes
- public `CONTRIBUTING.md`
- public `CHANGELOG.md`

### Changed

- internal planning, audit, and process docs moved to local-only `.private-docs/`
- public docs and examples now form the tracked user-facing documentation surface
- RC-facing contract remains open for final downstream validation before first public release

### Notes

- This section should be trimmed into the first intentional release entry once `0.1.0-rc.1` or
  `0.1.0` is cut.

## Format

Each release entry should include:

- version and date
- whether the release is additive, corrective, or breaking
- public API additions
- public API removals or breaking changes
- typed error or ownership contract changes
- docs/examples updates that materially affect downstream use
