# Phase G Kickoff

Date: 2026-03-09

Purpose: establish the minimal Phase G execution baseline while preserving finalized Phase F evidence.

## Baseline

- Phase F hard-gate closure (`no-dr3`) is complete.
- Phase F records remain canonical historical evidence:
  - `docs/plans/phase-f-kickoff.md`
  - `docs/plans/phase-f-parity-matrix.md`
  - `docs/plans/phase-f-parity-ledger.md`
  - `docs/plans/phase-f-risk-burndown.md`

## Operating Mode

- Active execution state is Phase G kickoff baseline.
- `UT-E-003` and `UT-E-004` are in maintenance mode.
- Rust lane remains active for cadence checks; TypeScript lane remains archived historical evidence only.

## Reopen Triggers

- Reopen `UT-E-003` only if a new NIP-44 behavior class is discovered.
- Reopen `UT-E-004` only if a new secp-boundary behavior class is discovered.
- Depth-only reruns, fixture refreshes, dependency bumps, and toolchain updates are maintenance cadence
  work and do not reopen either item by default.

## Release-Readiness Checklist

- Keep rust-active parity cadence current (`tools/interop/rust-nostr-parity-all`).
- Run aggregate Zig gates after parity cadence reruns (`zig build test --summary all`, `zig build`).
- Keep Phase G and handoff docs consistent with rust-active / TS-archived governance.
- Track checklist progress and evidence updates without requiring remote setup work.

## Blocker Visibility

- `no-3uj` remains visible for git/Dolt remote + sync readiness.
- Operator note: `no-3uj` is deferred-by-operator for now and is not the current execution focus.

## Immediate Next Action

1. Continue maintenance-mode cadence from the Phase G baseline.
2. Advance the release-readiness checklist items that do not require remote setup.
