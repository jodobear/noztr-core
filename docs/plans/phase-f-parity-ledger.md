# Phase F Parity Ledger (Model v1)

Date: 2026-03-09

Canonical ledger for parity status, deliberate differences, `noztr` uniqueness, and smallest next
actions.

## Feature Parity Status

| Scope | Status | Evidence |
| --- | --- | --- |
| Rust lane (`tools/interop/rust-nostr-parity-all`) | `HARNESS_COVERED` for 11/16 implemented NIPs; 5/16 `NOT_COVERED_IN_THIS_PASS` with explicit runtime capability probes; `0` `LIB_UNSUPPORTED` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` |
| TypeScript lane (`tools/interop/ts-nostr-parity-all`) | `HARNESS_COVERED` for 12/16 implemented NIPs (`NIP-02/09/65` added); 4/16 `NOT_COVERED_IN_THIS_PASS` with explicit runtime capability probes (`NIP-40/45/50/70`); `0` `LIB_UNSUPPORTED` | `npm install && npm run run` (in `tools/interop/ts-nostr-parity-all`) |
| Full side-by-side matrix | canonical and current | `docs/plans/phase-f-parity-matrix.md` |

## Deliberate Differences

| Delta | Why deliberate | Current taxonomy | Next smallest action |
| --- | --- | --- | --- |
| TS lane still leaves NIP-40/45/50/70 unexecuted despite probe evidence | this pass prioritizes truthful breadth now (`12/16`) and marks supported-but-unchecked scope explicitly | `NOT_COVERED_IN_THIS_PASS` | promote one TS probe (`NIP-50` or `NIP-45`) into full overlap check |
| Rust lane leaves NIP-40/45/50/70/77 unexecuted despite positive capability probes | this pass prioritizes harness depth on already-covered checks | `NOT_COVERED_IN_THIS_PASS` | promote one rust probe (`NIP-50` recommended) into full overlap check |
| `LIB_UNSUPPORTED` claims require executable proof of no public API path | avoid overloaded unsupported wording and preserve model-v1 semantics | none currently emitted in either lane | keep probe-first rule in both harnesses |

## noztr Uniqueness Points

| Point | Why it matters | Evidence |
| --- | --- | --- |
| Strict taxonomy + depth model in harness output | keeps pass/fail semantics machine-readable and stable | `tools/interop/rust-nostr-parity-all/src/main.rs`, `tools/interop/ts-nostr-parity-all/index.ts` |
| Exit code policy tied only to `HARNESS_COVERED` failures | avoids false negatives from intentionally deferred checks | same harness files |
| Strict default wording preserved | parity model does not alter strictness/default policy | `docs/plans/decision-log.md`, `docs/plans/build-plan.md` |

## Next Actions

1. Promote rust `NIP-50` capability probe to a full `HARNESS_COVERED` overlap check.
2. Promote one TS probe-backed item (`NIP-45` or `NIP-50`) to a full `HARNESS_COVERED` check.
3. Keep matrix and ledger authoritative; lane docs remain execution notes.
