# Phase F Parity Matrix (Model v1)

Date: 2026-03-09

Canonical side-by-side matrix for implemented `noztr` NIPs across rust and TypeScript parity-all lanes.

## Taxonomy and Depth

- Taxonomy: `LIB_SUPPORTED`, `HARNESS_COVERED`, `NOT_COVERED_IN_THIS_PASS`, `LIB_UNSUPPORTED`.
- Depth: `BASELINE`, `EDGE`, `DEEP`.
- Default for this rollout: implemented NIPs without an executed overlap check are
  `NOT_COVERED_IN_THIS_PASS`.
- Support-versus-coverage rule: `LIB_UNSUPPORTED` appears only when the harness executes an explicit
  runtime capability probe proving unsupported status.

## Matrix

| NIP | Rust taxonomy | Rust depth | Rust result | Rust evidence command | TS taxonomy | TS depth | TS result | TS evidence command | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| NIP-01 | `HARNESS_COVERED` | `BASELINE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | event baseline checks + tamper negative |
| NIP-02 | `HARNESS_COVERED` | `BASELINE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `BASELINE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS baseline: kind-3 + `p` tag structural check |
| NIP-09 | `HARNESS_COVERED` | `BASELINE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `BASELINE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS baseline: kind-5 + `e` tag structural check |
| NIP-11 | `HARNESS_COVERED` | `BASELINE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS lane: mocked fetch relay-info overlap |
| NIP-13 | `HARNESS_COVERED` | `BASELINE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | deterministic PoW sample + edge zero-bits case |
| NIP-19 | `HARNESS_COVERED` | `EDGE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | roundtrip + invalid-path checks |
| NIP-21 | `HARNESS_COVERED` | `EDGE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | URI boundary checks |
| NIP-40 | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS probe: public structural expiration-tag path is supported |
| NIP-42 | `HARNESS_COVERED` | `EDGE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | auth event checks + mismatch negative |
| NIP-44 | `HARNESS_COVERED` | `DEEP` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `DEEP` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | fixture replay + deterministic encrypt/decrypt |
| NIP-45 | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS probe: `Relay.count` public API exists |
| NIP-50 | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS probe: `matchFilter` accepts `search` filter field |
| NIP-59 | `HARNESS_COVERED` | `BASELINE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS lane: create/seal/wrap/unwrap + wrong-recipient negative |
| NIP-65 | `HARNESS_COVERED` | `EDGE` | `PASS` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `BASELINE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS baseline: kind-10002 + `r` tags (`read`/`write`) structural check |
| NIP-70 | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS probe: public structural `['-']` protected-tag path is supported |
| NIP-77 | `NOT_COVERED_IN_THIS_PASS` | `BASELINE` | `NOT_RUN` | `cargo run --manifest-path tools/interop/rust-nostr-parity-all/Cargo.toml` | `HARNESS_COVERED` | `EDGE` | `PASS` | `npm run run` (in `tools/interop/ts-nostr-parity-all`) | TS lane: storage/negentropy baseline + sealed-insert edge |

Policy note: parity model v1 adoption introduces no frozen-default or strictness-policy change.
