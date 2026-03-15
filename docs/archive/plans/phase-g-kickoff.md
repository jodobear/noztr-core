# Phase G Kickoff

Date: 2026-03-09

Purpose: establish the minimal Phase G execution baseline while preserving finalized Phase F evidence.

## Baseline

- Phase F hard-gate closure (`no-dr3`) is complete.
- Phase F records remain canonical historical evidence:
  - `docs/archive/plans/phase-f-kickoff.md`
  - `docs/archive/plans/phase-f-parity-matrix.md`
  - `docs/archive/plans/phase-f-parity-ledger.md`
  - `docs/archive/plans/phase-f-risk-burndown.md`

## Operating Mode

- Active execution state is Phase G kickoff baseline.
- `UT-E-003` and `UT-E-004` are in maintenance mode.
- Rust lane remains active for cadence checks; TypeScript lane remains archived historical evidence only.

## Baseline Cadence Evidence

- Date: 2026-03-09.
- `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml`: PASS
  (`SUMMARY pass=16 fail=0 harness_covered=16 total=16`).
- `zig build test --summary all`: PASS (`Build Summary: 8/8 steps succeeded; 460/460 tests passed`).
- `zig build`: PASS (completed without errors).

## Reopen Triggers

- Reopen `UT-E-003` only if a new NIP-44 behavior class is discovered.
- Reopen `UT-E-004` only if a new secp-boundary behavior class is discovered.
- Depth-only reruns, fixture refreshes, dependency bumps, and toolchain updates are maintenance cadence
  work and do not reopen either item by default.

## Release-Readiness Checklist

- [done] Non-remote cadence baseline is current on rust-active lane
  (`tools/interop/rust-nostr-parity-all`).
- [done] Aggregate Zig quality gates are current for the same non-remote pass
  (`zig build test --summary all`, `zig build`).
- [done] `UT-E-003` and `UT-E-004` remain maintenance-mode only; no burn-down expansion without new
  behavior-class discovery.
- [done] rust-active / TS-archived governance wording is aligned in active Phase G docs.
- [done] Artifact consistency confirmed: `docs/plans/build-plan.md`,
  `docs/archive/plans/phase-g-kickoff.md`, and `handoff.md` are aligned; `docs/archive/plans/phase-f-risk-burndown.md`
  is retained as historical evidence for this checklist baseline.
- [done] Complete local-only Phase G closure while remote setup remains deferred and out of scope.

## Blocker Visibility

- `no-3uj` remains visible for git/Dolt remote + sync readiness.
- Operator note: `no-3uj` is deferred-by-operator for now and is not the current execution focus.

## Closure Update

- Date: 2026-03-10.
- Phase G is complete on local-only release-readiness criteria.
- Remote readiness `no-3uj` remains deferred-by-operator and is not part of the completed local
  closure gate.
- Next active phase is Phase H kickoff for additional NIP expansion planning.
- Active successor artifacts:
  - `docs/plans/phase-h-kickoff.md`
  - `docs/plans/phase-h-additional-nips-plan.md`

## Immediate Next Action

1. Preserve Phase G as the historical local-closure baseline.
2. Start Phase H kickoff and additional-NIP expansion planning.
