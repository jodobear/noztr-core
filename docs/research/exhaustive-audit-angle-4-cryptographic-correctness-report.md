---
title: Exhaustive Audit Angle 4 Cryptographic Correctness Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_cryptographic_correctness
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
canonical: true
---

# Exhaustive Audit Angle 4: Cryptographic Correctness / Secret Handling

- date: 2026-03-17
- issue: `no-dwu`
- packet: `no-ard`
- author: Codex

## Purpose

- evaluate whether `noztr`'s cryptography-bearing protocol surfaces are locally correct at the
  protocol-framing layer
- check signature/verification flow, transcript construction, nonce/randomness contracts, secret
  wiping, and key-shape validation where `noztr` itself owns the boundary logic
- this angle does not attempt to re-prove `secp256k1` or `libwally` primitive correctness; that is
  treated as backend trust and reviewed separately under backend-wrapper quality

## Scope

Reviewed directly in this pass:
- `src/nip01_event.zig`
- `src/nostr_keys.zig`
- `src/nip06_mnemonic.zig`
- `src/bip85_derivation.zig`
- `src/nip26_delegation.zig`
- `src/nip42_auth.zig`
- `src/nip44.zig`
- `src/nip49_private_key_encryption.zig`
- `src/nip57_zaps.zig`
- `src/nip59_wrap.zig`

Explicit exclusions:
- deep review of backend-wrapper extraction quality
- performance posture
- non-cryptographic implemented NIP surfaces

## Standards

- `docs/plans/audit-angle-standards.md`
  - signature and verification flows that depend on protocol framing
  - transcript correctness for encryption, auth, wrap, and zap-adjacent surfaces
  - randomness and nonce expectations plus caller contracts
  - secret wiping, lifetime, and key-shape handling
  - cryptographic preconditions documented at the public boundary
- for this angle, correctness means local framing and boundary behavior are sound; it does not mean
  the underlying pinned crypto libraries were re-derived from first principles

## Evidence Sources

Primary:
- reviewed local crypto-bearing modules listed in scope
- co-located tests in those modules

Secondary:
- active control docs that freeze current boundary posture:
  - `docs/plans/build-plan.md`
  - `docs/plans/phase-h-remaining-work.md`
  - `docs/plans/noztr-sdk-ownership-matrix.md`

Weak / external-trust evidence:
- pinned backend dependency assumption in `build.zig.zon`

## Coverage

Explicitly checked:
- `nip01_event` and `nostr_keys` still keep event-id computation and event signing/verification
  aligned
- `NIP-06` and `BIP-85` still validate seed/key shape and wipe sensitive intermediate material
- `NIP-26`, `NIP-42`, `NIP-44`, `NIP-49`, `NIP-57`, and `NIP-59` still preserve signer
  continuity, transcript ordering, and key-shape validation at the public boundary
- deterministic fixed-input paths are distinguished from random/default paths in:
  - `NIP-44`
  - `NIP-49`
  - `NIP-59`
- secret-bearing staging buffers are wiped after use on the local paths that own them

Explicitly not checked:
- mathematical correctness of the underlying `secp256k1` and `libwally` primitives
- side-channel properties of third-party backend code
- benchmark-level performance implications of wipe/copy behavior

Matrix rows touched:
- `Build and packaging surface`: `not applicable`
- `Event/message/filter/key core`: `complete`
- `Implemented NIP surfaces in docs/plans/implemented-nip-audit-report.md`: `not applicable`
- `Crypto backend wrapper`: `not applicable`
- `Derivation and backend boundary`: `complete`
- `Cryptography-bearing protocol consumers`: `complete`
- `Freeze-critical control and audit docs`: `not applicable`

## Findings

- none

No new cryptographic-correctness defect was found in the locally owned protocol framing. The
reviewed surfaces still:
- validate key shape before signing or decrypting
- maintain signer continuity where the protocol requires it
- separate deterministic vector helpers from random/default flows
- wipe sensitive intermediate buffers on the local paths that materialize them

## Accepted Exceptions

- scope:
  - fixed-input deterministic helper paths in
    [nip44.zig](/workspace/projects/noztr/src/nip44.zig),
    [nip49_private_key_encryption.zig](/workspace/projects/noztr/src/nip49_private_key_encryption.zig),
    and [nip59_wrap.zig](/workspace/projects/noztr/src/nip59_wrap.zig)
- rationale:
  - these paths are intentional for parity vectors, deterministic transcript construction, and
    testability
  - the default/randomized paths remain present and the fixed-input paths are explicit in naming
- risk:
  - misuse remains possible if callers intentionally feed fixed nonces or salts in live flows
- reversal trigger:
  - reopen if the docs/examples angle finds these deterministic helpers are being taught as the
    default operational path rather than as explicit vector or bounded-construction helpers

- scope:
  - backend primitive correctness for `secp256k1` and `libwally`
- rationale:
  - this angle reviewed local framing and secret handling, not the internals of pinned upstream
    cryptographic code
- risk:
  - local correctness confidence still depends on backend trust for primitive operations
- reversal trigger:
  - reopen if backend-quality review or external evidence shows a primitive or wrapper-level defect
    that invalidates the local framing conclusions

## Residual Risk

- the main remaining unknown is backend trust, not local transcript framing
- the repo still depends on later backend-quality review to judge whether the wrapper seams are
  sharp enough for freeze confidence

## Suggested Remediation Candidates

- none from this angle

## Completion Statement

This angle is complete because:
- the cryptography-bearing protocol surfaces were checked directly
- local signer/transcript/nonce/wiping contracts remain coherent
- no new defect was found in the protocol-owned cryptographic framing layer

Reopen this angle if:
- backend-wrapper review finds a seam problem that invalidates the local correctness story
- later docs/examples review shows deterministic helper misuse in the teaching surface
- new evidence shows a signer-continuity, transcript-order, or secret-lifetime defect in a
  reviewed surface
