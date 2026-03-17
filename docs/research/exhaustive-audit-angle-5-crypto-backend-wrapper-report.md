---
title: Exhaustive Audit Angle 5 Crypto Backend Wrapper Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_crypto_backend_quality
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
canonical: true
---

# Exhaustive Audit Angle 5: Crypto / Backend-Wrapper Quality

- date: 2026-03-17
- issue: `no-ys3`
- packet: `no-ard`
- author: Codex

## Purpose

- evaluate whether `noztr`'s crypto backend seams are sharp, explicit, and maintainable enough for
  pre-freeze confidence
- focus on dependency boundary discipline, backend state handling, wrapper shape, error mapping,
  and extraction pressure
- this angle does not re-prove protocol framing correctness; that was handled in angle 4

## Scope

Reviewed directly in this pass:
- `build.zig.zon`
- `src/crypto/secp256k1_backend.zig`
- `src/nip06_mnemonic.zig`
- `src/bip85_derivation.zig`
- crypto-boundary consumers that exercise the wrapper:
  - `src/nip26_delegation.zig`
  - `src/nip42_auth.zig`
  - `src/nip44.zig`
  - `src/nip49_private_key_encryption.zig`
  - `src/nip57_zaps.zig`
  - `src/nip59_wrap.zig`

Explicit exclusions:
- benchmark-level performance work
- non-crypto public API consistency outside wrapper implications

## Standards

- `docs/plans/audit-angle-standards.md`
  - `secp256k1` boundary sharpness
  - `libwally` boundary sharpness
  - error mapping quality
  - backend state handling
  - source pinning assumptions and dependency-boundary discipline
- backend-quality pressure must be evidence-backed before it can argue for extraction or rewrite

## Evidence Sources

Primary:
- local backend and derivation code listed in scope
- `build.zig.zon` for source pinning

Secondary:
- current accepted boundary rationale in
  `docs/plans/post-audit-improvement-plan.md`

## Coverage

Explicitly checked:
- pinned backend sources are still commit- and hash-pinned in `build.zig.zon`
- `secp256k1_backend` still provides typed error mapping instead of leaking raw backend errors
- `NIP-06` backend initialization is isolated to one internal state cell rather than ambient
  global reachability
- `BIP-85` reaches the `libwally` backend directly and was checked for boundary sharpness rather
  than just cryptographic framing correctness
- crypto-bearing consumers still use the wrapper boundary rather than bypassing it for secp

Explicitly not checked:
- upstream backend source internals
- packaging/distribution concerns outside the pinned source declarations

Matrix rows touched:
- `Build and packaging surface`: `complete`
- `Event/message/filter/key core`: `not applicable`
- `Implemented NIP surfaces in docs/plans/implemented-nip-audit-report.md`: `not applicable`
- `Crypto backend wrapper`: `complete`
- `Derivation and backend boundary`: `complete`
- `Cryptography-bearing protocol consumers`: `complete`
- `Freeze-critical control and audit docs`: `not applicable`

## Findings

### Older crypto-bearing leaves still collapse backend outage into the wrong public errors

- severity: `medium`
- scope:
  - [nip44.zig](/workspace/projects/noztr/src/nip44.zig#L54)
  - [nip26_delegation.zig](/workspace/projects/noztr/src/nip26_delegation.zig#L374)
  - [nip26_delegation.zig](/workspace/projects/noztr/src/nip26_delegation.zig#L385)
- why it matters:
  - the backend seam is only sharp if operational/backend failure stays distinguishable from
    caller-blame failure
  - these older leaves still collapse backend outage into user-facing errors that imply bad key or
    bad entropy rather than backend unavailability
- evidence:
  - `nip44_get_conversation_key(...)` maps `error.BackendUnavailable` from
    `derive_shared_secret_x(...)` to `error.EntropyUnavailable`
  - `NIP-26` maps `BackendUnavailable` to `InvalidSignature` on verify and `InvalidSecretKey` on
    sign
- remediation pressure:
  - targeted fix

### The libwally boundary is still fragmented and BIP-85 bootstraps readiness indirectly

- severity: `medium`
- scope:
  - [nip06_mnemonic.zig](/workspace/projects/noztr/src/nip06_mnemonic.zig#L23)
  - [nip06_mnemonic.zig](/workspace/projects/noztr/src/nip06_mnemonic.zig#L151)
  - [bip85_derivation.zig](/workspace/projects/noztr/src/bip85_derivation.zig#L4)
  - [bip85_derivation.zig](/workspace/projects/noztr/src/bip85_derivation.zig#L219)
- why it matters:
  - `libwally` is not behind one narrow seam yet
  - `NIP-06` owns one internal backend-state cell, but `BIP-85` reaches `libwally` directly and
    uses `nip06_mnemonic.mnemonic_validate(...)` on a hard-coded mnemonic as its backend
    readiness probe
  - that keeps the backend boundary functionally correct but less sharp and more coupled than the
    rest of the repo’s wrapper posture
- evidence:
  - direct `libwally` imports exist in both `nip06_mnemonic.zig` and `bip85_derivation.zig`
  - `bip85_derivation.ensure_backend()` succeeds by interpreting the `InvalidChecksum` path from
    `nip06_mnemonic.mnemonic_validate(...)` as evidence that the backend was initialized
- remediation pressure:
  - bounded redesign

### The secp wrapper still carries mutable verification counters in the production module

- severity: `low`
- scope:
  - [secp256k1_backend.zig](/workspace/projects/noztr/src/crypto/secp256k1_backend.zig#L30)
  - [secp256k1_backend.zig](/workspace/projects/noztr/src/crypto/secp256k1_backend.zig#L32)
  - [secp256k1_backend.zig](/workspace/projects/noztr/src/crypto/secp256k1_backend.zig#L42)
- why it matters:
  - the wrapper seam is otherwise narrow and typed
  - the embedded mutable verify counter is test-oriented state living in the production wrapper
    surface, which weakens minimalism and makes the seam slightly less crisp than it could be
- evidence:
  - `verify_signature_call_count`, `reset_counters()`, and
    `get_verify_signature_call_count()` live in the same public wrapper module as the actual
    production signing, verify, and ECDH helpers
- remediation pressure:
  - targeted fix

## Accepted Exceptions

- scope:
  - [build.zig.zon](/workspace/projects/noztr/build.zig.zon#L5)
- rationale:
  - both approved crypto backends remain pinned by commit and content hash
- risk:
  - pinning controls provenance, not upstream implementation quality
- reversal trigger:
  - reopen if dependency policy changes or a pin drifts away from commit-plus-hash locking

- scope:
  - [nip06_mnemonic.zig](/workspace/projects/noztr/src/nip06_mnemonic.zig#L23)
- rationale:
  - the once-only `libwally` init state is still confined to one internal cell rather than spread
    across multiple public entry points
- risk:
  - this remains a global backend-state seam even though it is now isolated
- reversal trigger:
  - reopen if more libwally lifecycle state escapes into unrelated modules or public API shape

## Residual Risk

- the backend story is materially better than a broad ambient-state design, but two weaknesses
  remain:
  - some older leaves still misclassify backend outage at the public boundary
  - the `libwally` seam is less consolidated than the rest of the crypto surface
- the main design pressure from this angle is targeted fix plus bounded extraction/cleanup pressure,
  not major rewrite pressure

## Suggested Remediation Candidates

- targeted fix
  - repair backend-outage mapping in `NIP-44` and `NIP-26` so operational/backend failure does not
    masquerade as caller fault or entropy failure
- bounded redesign
  - consolidate `libwally` readiness and derivation entry points behind one clearer backend seam so
    `BIP-85` does not bootstrap through `mnemonic_validate(...)`
- targeted fix
  - move verify-counter helpers out of the production secp wrapper path or isolate them to test-only
    coverage support

## Completion Statement

This angle is complete because:
- the pinned backend surface, wrapper module, isolated `NIP-06` state, and `BIP-85` backend path
  were reviewed directly
- the main remaining backend-quality issues are now explicit and severity-ranked
- the resulting pressure is bounded redesign pressure, not broad rewrite pressure by itself

Reopen this angle if:
- later Zig/API/performance angles show the fragmented backend seam causes wider systemic problems
- dependency policy changes
- new evidence shows raw backend errors or lifecycle state leaking beyond the current named scope
