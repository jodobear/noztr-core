---
title: Zig Patterns
doc_type: release_guide
status: active
owner: noztr
read_when:
  - contributing_zig_code
  - reviewing_implementation_shape
  - learning_noztr_safe_defaults
canonical: true
---

# Zig Patterns

These are the preferred implementation patterns for `noztr`.

They are intentionally practical. This page is for contributors who need to know what “good
noztr-style Zig” looks like in code review.

## Preferred Patterns

### 1. Caller-owned output

Preferred:

- caller provides output storage
- function returns the written slice or typed success value

Why:

- ownership stays explicit
- runtime memory stays bounded
- output sizing problems stay visible

### 2. Staged boundary checks

Preferred order:

1. size or cap check
2. shape parse
3. semantic validation
4. mutation, verification, or cryptographic work

Why:

- malformed input is rejected before deeper invariants matter
- partial mutation bugs are easier to avoid
- error contracts stay clearer

### 3. Typed error surfaces

Preferred:

- precise error unions at public boundaries
- explicit mapping for invalid input, capacity, and backend failures

Why:

- the failure contract becomes part of the API
- downstream callers and tests can reason about the surface directly

### 4. Explicit integer widths

Preferred:

- `u16`, `u32`, `u64` where the protocol or bounds are known

Why:

- protocol state and serialization stay architecture-stable
- contracts are easier to audit than `usize`-shaped surfaces

### 5. Small pure helpers

Preferred:

- small helpers that do one bounded thing
- state transitions at explicit edges

Why:

- tests get simpler
- review gets simpler
- deterministic behavior is easier to prove

### 6. Checked entry points for risky boundaries

Preferred:

- one obvious safe trust-boundary call when misuse risk is high

Why:

- callers have a canonical safe path
- review and examples can teach one clear boundary contract

### 7. `defer` and `errdefer` for cleanup

Preferred:

- `defer` for normal cleanup
- `errdefer` for error-path cleanup

Why:

- secret handling and temporary buffers are easier to keep correct
- cleanup logic stays local to the resource it protects

### 8. Hostile examples for boundary-heavy surfaces

Preferred:

- one direct example
- one hostile example where the boundary is easy to misuse

Why:

- the intended failure contract becomes visible to humans and LLMs

## Practical Module Patterns

Good `noztr`-style module behavior usually looks like:

- parse/build helpers that stay deterministic
- explicit checked wrappers at dangerous boundaries
- pure reducers for replay/state-application logic
- compatibility behavior isolated instead of silently folded into the default path

## Review Heuristics

In review, good Zig for `noztr` usually feels like:

- obvious control flow
- explicit ownership
- explicit limits
- explicit error meaning
- bounded helper shape

If the code feels clever, hidden, or sprawling, it is probably drifting away from the style we
want.

## Related Pages

- [NOZTR Style](/workspace/projects/noztr/docs/release/noztr-style.md)
- [zig-anti-patterns.md](/workspace/projects/noztr/docs/release/zig-anti-patterns.md)
- [errors-and-ownership.md](/workspace/projects/noztr/docs/release/errors-and-ownership.md)
