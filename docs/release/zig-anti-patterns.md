---
title: Zig Anti-Patterns
doc_type: release_guide
status: active
owner: noztr
read_when:
  - contributing_zig_code
  - reviewing_trust_boundary_risks
  - avoiding_noztr_footguns
canonical: true
---

# Zig Anti-Patterns

These are the common implementation shapes contributors should avoid in `noztr`.

The issue is not “style preference.” These patterns usually make the public contract less bounded,
less auditable, or less deterministic.

## Avoid These Patterns

### 1. Broad error funnels

Avoid:

- collapsing many public failure causes into one vague error
- `catch` paths that hide the real cause at the trust boundary

Why:

- downstream callers lose the real contract
- invalid input, capacity failure, and backend outage become harder to distinguish

### 2. Heap-first runtime paths

Avoid:

- implicit growth containers in core runtime paths
- public APIs that quietly allocate to make boundary calls “easy”

Why:

- ownership gets blurry
- bounded-memory expectations weaken

### 3. Parse-and-mutate in one pass

Avoid:

- mutating output or state before shape and semantic checks are complete

Why:

- malformed input can leave partial state behind
- review and tests get harder

### 4. Hidden compatibility in the default path

Avoid:

- silently accepting legacy or alternate shapes in the strict default path

Why:

- the kernel contract becomes fuzzy
- callers no longer know what the default surface really promises

### 5. `usize` in protocol-facing contracts

Avoid:

- storing or serializing protocol state with architecture-dependent widths

Why:

- it weakens portability and contract clarity

### 6. Silent truncation or clamping

Avoid:

- quietly clipping lengths, tags, or identifiers

Why:

- malformed input gets normalized into surprising behavior
- caller mistakes become harder to detect

### 7. Bool-only boundary validators

Avoid:

- public validators that only return `bool` when the failure reason materially matters

Why:

- callers lose useful diagnostics
- test coverage gets weaker

### 8. Shared mutable scratch

Avoid:

- global or shared mutable decode scratch for runtime operations

Why:

- aliasing and stale-state bugs become easier to introduce
- explicit ownership is lost

### 9. Contract-layer confusion in examples

Avoid:

- examples that mix full object JSON, canonical preimage, envelopes, and checked wrappers as if
  they were the same thing

Why:

- examples become plausible but wrong
- downstream users learn the wrong mental model

## Review Smells

If you see these, stop and challenge the change:

- “it’s easier if we just allocate here”
- “we can normalize that malformed input silently”
- “the exact error probably doesn’t matter”
- “the helper scans the whole string, but it’s fine”
- “the example is close enough”

Those are the kinds of shortcuts that create drift later.

## Related Pages

- [NOZTR Style](/workspace/projects/noztr/docs/release/noztr-style.md)
- [zig-patterns.md](/workspace/projects/noztr/docs/release/zig-patterns.md)
- [errors-and-ownership.md](/workspace/projects/noztr/docs/release/errors-and-ownership.md)
