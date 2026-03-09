# Phase F Kickoff

Date: 2026-03-09

Purpose: keep Phase F tracking normalized to current post-I7 reality with rust as the only active
parity gate lane.

## Baseline

- Active execution state is Phase F on post-I7 baseline (`I0`-`I7` complete).
- Carry-forward accepted risks remain: `UT-E-001`, `UT-E-002`, `UT-E-003`, `UT-E-004`, `A-D-001`.
- Frozen defaults and strictness posture are unchanged (`D-001`..`D-004`).
- Canonical I7 evidence remains:
  - `docs/plans/i7-regression-evidence.md`
  - `docs/plans/i7-api-contract-trace-checklist.md`
  - `docs/plans/i7-phase-f-kickoff-handoff.md`

## Parity Gate Status

- Active lane: rust only (`tools/interop/rust-nostr-parity-all`).
- Current rust status: `16/16` implemented NIPs are `HARNESS_COVERED`, `DEEP`, `PASS`.
- Active cadence commands:
  - `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml`
  - `zig build test --summary all && zig build`
- Canonical parity artifacts:
  - `docs/plans/phase-f-parity-matrix.md`
  - `docs/plans/phase-f-parity-ledger.md`

## Archived TypeScript Evidence

- `tools/interop/ts-nostr-parity-all` is archived historical evidence only (not an active gate lane).
- Historical TS outcomes remain preserved in:
  - `docs/plans/phase-f-parity-matrix.md`
  - `docs/plans/phase-f-parity-ledger.md`
  - `docs/plans/phase-f-risk-burndown.md`

## Burn-Down Status

- `UT-E-003` and `UT-E-004` burn-down remains active with recorded pass/no-drift checkpoints.
- Replay fixtures and persistent cross-language harness evidence remain available for depth expansion.
- Canonical burn-down tracker: `docs/plans/phase-f-risk-burndown.md`.

## Next Actions

1. Convert any remaining old TS cadence wording into explicit archive-only sections.
2. Re-run and record rust parity on dependency/version bumps.
3. Continue `UT-E-003` differential replay depth expansion.
4. Continue `UT-E-004` secp boundary depth expansion.
5. Keep trigger-governance rule unchanged: decision-log entry required before any default change.
