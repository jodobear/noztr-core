---
title: NOZTR Style
doc_type: release_guide
status: active
owner: noztr
read_when:
  - contributing_code
  - understanding_noztr_engineering_defaults
  - reviewing_protocol_kernel_changes
canonical: true
---

# NOZTR Style

This is the public contributor-facing style guide for `noztr`.

It explains how the library is supposed to feel and why some changes fit the repo while others do
not.

For contribution workflow, start with [CONTRIBUTING.md](/workspace/projects/noztr/CONTRIBUTING.md).

## What This Library Optimizes For

`noztr` is trying to be:

- a deterministic Nostr protocol kernel
- bounded in memory and runtime behavior
- explicit about trust boundaries
- simple to audit and simple to build on

That means code should prefer:

- explicit contracts
- explicit ownership
- explicit failure modes
- narrow scope

It should avoid:

- hidden allocation growth
- hidden workflow assumptions
- permissive parsing for convenience alone
- broad helpers that mix protocol logic with application policy

## Core Style Rules

- keep protocol behavior deterministic for the same input
- keep public trust-boundary failures typed and explicit
- keep ownership explicit and caller-buffer-first on runtime paths
- keep runtime work bounded
- keep kernel logic separate from SDK, transport, storage, and UI policy
- prefer the simplest behavior that is correct, bounded, and ecosystem-compatible

## Scope Discipline

Good kernel work:

- parsing
- validation
- serialization
- verification
- pure reducers
- deterministic protocol glue

Bad kernel creep:

- session orchestration
- relay workflow
- redirects or app launch behavior
- storage or cache policy
- UI policy
- broad convenience wrappers that hide higher-layer decisions

If a change feels like app or SDK workflow, it probably does not belong in `noztr`.

## Memory And Ownership

The default runtime posture is:

- caller-owned buffers
- explicit output slices
- fixed-capacity or bounded state
- no heap-first public API style

Contributors should preserve that feel unless there is strong evidence that a different approach is
worth the cost.

See also:

- [errors-and-ownership.md](/workspace/projects/noztr/docs/release/errors-and-ownership.md)

## Error Style

`noztr` prefers typed boundary errors over vague failure funnels.

Public callers should be able to tell the difference between:

- invalid input
- capacity failure
- backend outage
- intentionally unsupported behavior

Do not collapse those into one generic error unless the surface truly has no more precise public
contract.

## Strictness Without Fussiness

`noztr` is strict by default, but it should not become fussy for its own sake.

Good strictness:

- rejecting malformed or contradictory input
- preserving canonical emitted output
- keeping trust-boundary behavior explicit

Bad fussiness:

- adding narrow special-case rules without clear value
- rejecting harmless valid variation just to express purity
- widening the typed error surface when one existing error already says enough

The goal is an auditable kernel, not a performative one.

## Compatibility Model

The library uses a two-layer idea:

- Layer 1: strict protocol kernel
- higher layers: adapters, SDK ergonomics, and workflow behavior

Compatibility should be explicit and isolated. Do not quietly smuggle permissive behavior into the
default kernel path.

## Practical Review Questions

Before landing a change, ask:

- does this stay inside protocol-kernel scope?
- does it keep ownership and failure contracts explicit?
- does it improve correctness, determinism, or downstream usability?
- does it add complexity that the trust boundary does not justify?
- does it belong in `noztr`, or in a higher layer?

## Next Pages

- [zig-patterns.md](/workspace/projects/noztr/docs/release/zig-patterns.md)
- [zig-anti-patterns.md](/workspace/projects/noztr/docs/release/zig-anti-patterns.md)
- [compatibility-and-support.md](/workspace/projects/noztr/docs/release/compatibility-and-support.md)
