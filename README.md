# noztr-core

Pure Zig Nostr protocol library with a stdlib-first dependency policy and approved pinned crypto
backend exceptions.

## What noztr-core is

`noztr-core` is the public library name for this protocol-kernel layer.

The Zig package/import name in examples remains `noztr`.

- A deterministic, bounded, compatibility-aware protocol-kernel implementation for Nostr.
- Built as a static library with deterministic, bounded behavior targets.
- Focused on protocol parsing, validation, serialization, and trust-boundary helpers.
- Keeps non-crypto surfaces stdlib-first and isolates approved crypto backends behind narrow boundary
  modules.

For the release-facing explanation of what `noztr-core` is trying to do, why it exists, its benefits
and limitations, and how it compares to more mature libraries, start with
[`docs/scope-and-tradeoffs.md`](docs/scope-and-tradeoffs.md).
For the public docs route as a whole, start with
[`docs/INDEX.md`](docs/INDEX.md).
Key public entry points:
- [`docs/getting-started.md`](docs/getting-started.md)
- [`docs/reference/contract-map.md`](docs/reference/contract-map.md)
- [`docs/reference/api-reference.md`](docs/reference/api-reference.md)
- [`examples/README.md`](examples/README.md)

## Public release posture

- `noztr-core` and `noztr-sdk` are intended to be complementary layers:
  - `noztr-core` owns deterministic protocol-kernel work
  - `noztr-sdk` owns higher-level workflow, transport, and application-facing composition
- Public versioning policy is conservative:
  - treat the current line as pre-`1.0.0`
  - start the first intentional public release at `0.1.0`
  - reserve `1.0.0` for the point where the project is ready to defend the public contract as
    stable by default
- Supported NIP surface snapshot:
  - use [`docs/reference/nip-coverage.md`](docs/reference/nip-coverage.md) for the detailed
    export/status/example matrix
  - use [`docs/reference/contract-map.md`](docs/reference/contract-map.md) and
    [`examples/README.md`](examples/README.md) when you want the right route or example for a job

| Core | Identity and trust | Messaging and wrappers | Coordination and content |
| --- | --- | --- | --- |
| - [x] `NIP-01` | - [x] `NIP-05` | - [x] `NIP-04` | - [x] `NIP-23` |
| - [x] `NIP-02` | - [x] `NIP-11` | - [x] `NIP-17` | - [x] `NIP-24` |
| - [x] `NIP-03` | - [x] `NIP-13` | - [x] `NIP-18` | - [x] `NIP-28` (`split`) |
| - [x] `NIP-06` | - [x] `NIP-19` | - [x] `NIP-21` | - [x] `NIP-29` |
| - [x] `NIP-09` | - [x] `NIP-39` | - [x] `NIP-22` | - [x] `NIP-30` |
| - [x] `NIP-10` | - [x] `NIP-42` | - [x] `NIP-25` | - [x] `NIP-31` |
| - [x] `NIP-14` | - [x] `NIP-49` | - [x] `NIP-27` | - [x] `NIP-32` |
| - [x] `NIP-40` | - [x] `NIP-70` | - [x] `NIP-44` | - [x] `NIP-34` (`split`) |
| - [x] `NIP-91` | - [x] `NIP-98` (`split`) | - [x] `NIP-46` | - [x] `NIP-36` |
|  | - [x] `NIP-B7` (`split`) | - [x] `NIP-47` (`split`) | - [x] `NIP-37` |
|  |  | - [x] `NIP-51` | - [x] `NIP-38` |
|  |  | - [x] `NIP-57` (`split`) | - [x] `NIP-52` |
|  |  | - [x] `NIP-59` | - [x] `NIP-53` (`split`) |
|  |  | - [x] `NIP-61` (`split`) | - [x] `NIP-54` |
|  |  | - [x] `NIP-86` (`split`) | - [x] `NIP-56` |
|  |  |  | - [x] `NIP-58` |
|  |  |  | - [x] `NIP-64` |
|  |  |  | - [x] `NIP-65` |
|  |  |  | - [x] `NIP-66` (`split`) |
|  |  |  | - [x] `NIP-71` (`split`) |
|  |  |  | - [x] `NIP-72` (`split`) |
|  |  |  | - [x] `NIP-73` |
|  |  |  | - [x] `NIP-75` |
|  |  |  | - [x] `NIP-78` (`split`) |
|  |  |  | - [x] `NIP-84` |
|  |  |  | - [x] `NIP-88` |
|  |  |  | - [x] `NIP-89` (`split`) |
|  |  |  | - [x] `NIP-92` |
|  |  |  | - [x] `NIP-94` |
|  |  |  | - [x] `NIP-99` |
|  |  |  | - [x] `NIP-B0` |
|  |  |  | - [x] `NIP-C0` |

- Not supported:
  - [ ] `NIP-26`

- Optional I6 extension exports (build-flag gated): `NIP-45`, `NIP-50`, `NIP-77`
- Non-NIP bounded wallet helpers: Nostr-relevant `BIP-85` subset for lowercase-hex entropy text
  and English BIP39 child mnemonic/entropy

## Build and test

```bash
zig build lint
zig build test --summary all
zig build
```

The test gate currently includes the full root-module suite, a core-only root-module suite, and
the downstream `examples/` suite. Those counts overlap across configurations, so they should be
read as execution totals rather than unique logical test cases.

The lint gate is intentionally narrow and functional:

- `zig build lint` runs `zig fmt --check` across the tracked Zig/ZON surface
- build/test correctness remains enforced by `zig build test --summary all` and `zig build`

## Benchmark evidence

Published performance checks can be rerun with:

```bash
zig build empirical-benchmark -Doptimize=ReleaseFast
zig build rc-stress-throughput -Doptimize=ReleaseFast
zig build rc-stress-throughput-soak -Doptimize=ReleaseFast
zig build rc-stress-throughput-csv -Doptimize=ReleaseFast
zig build rc-stress-throughput-markdown -Doptimize=ReleaseFast
```

## Why noztr-core

Short version:

- `noztr-core` is trying to be a Zig-native protocol kernel, not a batteries-included Nostr app
  stack
- it favors deterministic, bounded, typed trust-boundary behavior over permissive convenience
- it is a better fit when you want to build your own SDK or app architecture on top of a narrow
  core

For the full positioning and comparison note, read
[`docs/scope-and-tradeoffs.md`](docs/scope-and-tradeoffs.md).

## Quick start

Use this route if you want the shortest path into the public surface.

1. Add the `noztr` Zig package dependency for `noztr-core`.
2. Pick the right symbol family:
   - core event/filter/message work:
     [`docs/reference/core-api-contracts.md`](docs/reference/core-api-contracts.md)
   - post-core jobs like `NIP-05`, `NIP-46`, `NIP-47`, `NIP-59`, `NIP-98`, `NIP-29`, `NIP-88`:
     [`docs/reference/contract-map.md`](docs/reference/contract-map.md)
3. Start from one direct example and, when available, one hostile example in
   [`examples/README.md`](examples/README.md).

## Common jobs

| Job | Start here | Example |
| --- | --- | --- |
| Parse, serialize, sign, or verify events | [`docs/reference/core-api-contracts.md`](docs/reference/core-api-contracts.md) | [`examples/nip01_example.zig`](examples/nip01_example.zig) |
| Identity lookup and bunker discovery | [`docs/reference/contract-map.md`](docs/reference/contract-map.md) | [`examples/discovery_recipe.zig`](examples/discovery_recipe.zig) |
| One-recipient gift wrap build and unwrap | [`docs/reference/contract-map.md`](docs/reference/contract-map.md) | [`examples/nip17_wrap_recipe.zig`](examples/nip17_wrap_recipe.zig) |
| Wallet Connect parsing and typed JSON contracts | [`docs/reference/contract-map.md`](docs/reference/contract-map.md) | [`examples/nip47_example.zig`](examples/nip47_example.zig) |
| HTTP auth event and header helpers | [`docs/reference/contract-map.md`](docs/reference/contract-map.md) | [`examples/nip98_example.zig`](examples/nip98_example.zig) |
| Group replay and poll tally reduction | [`docs/reference/contract-map.md`](docs/reference/contract-map.md) | [`examples/nip29_reducer_recipe.zig`](examples/nip29_reducer_recipe.zig), [`examples/nip88_example.zig`](examples/nip88_example.zig) |

## Use as a local Zig dependency

For local `noztr-sdk` or other downstream bootstrap work, consume the `noztr` Zig package as the
normal dependency for `noztr-core`.

`build.zig.zon`:

```zig
.{
    .dependencies = .{
        .noztr = .{
            .path = "../noztr-core",
        },
    },
}
```

`build.zig`:

```zig
const noztr_dependency = b.dependency("noztr", .{});
const noztr_module = noztr_dependency.module("noztr");
exe.root_module.addImport("noztr", noztr_module);
```

This repo now carries one downstream examples package and wires it into
`zig build test --summary all` so SDK-style local consumption stays checked:

- [`examples`](examples)
  - `consumer_smoke.zig` for the minimal dependency/import path
  - reference examples covering the implemented kernel NIP surface
  - dedicated adversarial examples for the highest-risk SDK-facing boundaries
  - a small public `nostr_keys` helper surface for x-only pubkey derivation and event signing
  - scenario-oriented recipe files for `NIP-03`, `NIP-04`, `NIP-05`, `NIP-06`, `NIP-17`, `BIP-85`,
    `NIP-39`, `NIP-46`, `NIP-51`, and `NIP-86`
  - open [`examples/README.md`](examples/README.md) for the SDK job map
  - open [`docs/reference/contract-map.md`](docs/reference/contract-map.md) for a task-to-symbol
    route across the main post-core surfaces
  - intended as the main downstream example surface for `noztr-sdk` and other SDK consumers

## Current Kernel Notes

- `NIP-06` now applies full BIP39-compatible `NFKD` normalization before mnemonic/passphrase seed
  derivation.
- Legacy `NIP-04` kind-4 direct-message helpers are available for strict local crypto, payload,
  and event-shape work.
- The `NIP-04` surface is DM-focused:
  - local encrypt/decrypt helpers target legacy kind-4 DM content
  - decrypt is intended for DM plaintext and rejects non-UTF-8 output
  - this does not widen `NIP-04` into a general raw-bytes or private-content compatibility layer
- Deprecated `NIP-04` private-list compatibility remains intentionally deferred; current private
  list support remains `NIP-44`-first.

## Repo layout

- `src/` - protocol modules and root exports
- `docs/` - public-facing documentation
- official NIP texts - use the upstream repository at `https://github.com/nostr-protocol/nips`
- `.private-docs/` - local-only internal planning, audit, and process material
- `tools/interop/` - parity harnesses and interop tooling
- `CONTRIBUTING.md` - repo contribution guide
- `CHANGELOG.md` - public release history
