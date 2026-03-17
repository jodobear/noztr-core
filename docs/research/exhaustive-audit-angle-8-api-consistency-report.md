---
title: Exhaustive Audit Angle 8 API Consistency Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_api_consistency
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
canonical: true
---

# Exhaustive Audit Angle 8: API Consistency / Determinism

- date: 2026-03-17
- issue: `no-ohgb`
- packet: `no-ard`
- author: Codex

## Purpose

- evaluate whether the public `noztr` surface is coherent enough to support freeze confidence
- focus on naming coherence, ownership-shape clarity, error-contract consistency, deterministic
  builder/parser expectations, and split-surface boundary sharpness
- this angle does not re-prove protocol correctness or crypto framing; it evaluates the public
  contract that callers see

## Scope

Reviewed directly in this pass:
- `src/root.zig`
- `src/errors.zig`
- `src/nip86_relay_management.zig`
- `src/nip46_remote_signing.zig`
- `src/nip25_reactions.zig`
- `docs/plans/noztr-sdk-ownership-matrix.md`
- `docs/plans/post-audit-improvement-plan.md`

Reused prior evidence explicitly:
- `docs/research/exhaustive-audit-angle-1-protocol-correctness-report.md`
- `docs/research/exhaustive-audit-angle-3-security-misuse-report.md`
- `docs/research/exhaustive-audit-angle-5-crypto-backend-wrapper-report.md`
- `docs/research/exhaustive-audit-angle-7-performance-memory-report.md`

Explicit exclusions:
- docs/discovery routing quality beyond API-boundary ownership evidence
- upstream backend quality outside its effect on public contract shape

## Standards

- `docs/plans/audit-angle-standards.md`
  - public naming coherence
  - ownership-shape coherence
  - error-contract consistency
  - canonical emitted output versus accepted valid input
  - split-surface boundary clarity

## Evidence Sources

Primary:
- local public API code in the reviewed modules
- exported facade and shared typed error surface
- ownership/boundary reference in `docs/plans/noztr-sdk-ownership-matrix.md`

Secondary:
- prior correctness, security, crypto-boundary, and performance angle reports
- accepted exception rationale in `docs/plans/post-audit-improvement-plan.md`

## Coverage

Explicitly checked:
- exported root facade and shared typed error namespace for naming and role clarity
- remaining public helper families already known to be boundary-sensitive
- whether accepted ownership-shape exceptions still look coherent as public API, not just as local
  implementation tradeoffs
- whether the `NIP-59` one-recipient outbound helper still sits on a clear kernel-vs-SDK split

Explicitly not checked:
- docs/discoverability quality as its own angle
- runtime ergonomics in real SDK/application code

Matrix rows touched:
- `Build and packaging surface`: `not applicable`
- `Exported facade and shared support`: `complete`
- `Event/message/filter/key core`: `complete`
- `Implemented NIP surfaces in docs/plans/implemented-nip-audit-report.md`: `complete`
- `Derivation and backend boundary`: `complete`
- `Cryptography-bearing protocol consumers`: `complete`
- `Public error-contract and invalid-vs-capacity families`: `complete`
- `Freeze-critical control and audit docs`: `not applicable`

## Findings

### NIP-86 public admin helpers still break deterministic API failure semantics on overlong input

- severity: `high`
- scope:
  - [nip86_relay_management.zig](/workspace/projects/noztr/src/nip86_relay_management.zig#L95)
  - [nip86_relay_management.zig](/workspace/projects/noztr/src/nip86_relay_management.zig#L152)
  - [nip86_relay_management.zig](/workspace/projects/noztr/src/nip86_relay_management.zig#L180)
- why it matters:
  - these are public entry points on a split surface that is supposed to present typed,
    deterministic trust-boundary behavior
  - debug-assert rejection on overlong input means callers do not get one stable public contract
    across build modes
- evidence:
  - `method_parse(...)`, `request_parse_json(...)`, and `response_parse_json(...)` assert bounded
    caller input before runtime invalid-input mapping
- remediation pressure:
  - targeted fix

### Direct NIP-46 helper APIs still rely on internal size invariants instead of stable public rejection

- severity: `medium`
- scope:
  - [nip46_remote_signing.zig](/workspace/projects/noztr/src/nip46_remote_signing.zig#L184)
  - [nip46_remote_signing.zig](/workspace/projects/noztr/src/nip46_remote_signing.zig#L217)
- why it matters:
  - `NIP-46` already went through broader hardening, so these direct helpers are now the notable
    API inconsistency inside that surface family
  - callers can still hit assertion semantics instead of deterministic `InvalidMethod` or
    `InvalidPermission`
- evidence:
  - `method_parse(...)` and `permission_parse(...)` assert bounded caller input length before
    runtime checks
- remediation pressure:
  - targeted fix

### NIP-25 exposes a public classifier whose direct-call contract is weaker than the rest of the surface

- severity: `low`
- scope:
  - [nip25_reactions.zig](/workspace/projects/noztr/src/nip25_reactions.zig#L68)
  - [nip25_reactions.zig](/workspace/projects/noztr/src/nip25_reactions.zig#L88)
- why it matters:
  - the parsed `NIP-25` path is typed and safe, but the standalone public helper asserts UTF-8
  - that makes the direct helper less self-defensive and slightly less coherent than adjacent
    parser-facing helpers
- evidence:
  - `reaction_classify_content(...)` asserts UTF-8 even though it is public and callable without
    the surrounding `reaction_parse(...)` validation path
- remediation pressure:
  - targeted fix

## Accepted Exceptions

- scope:
  - [nip05_identity.zig](/workspace/projects/noztr/src/nip05_identity.zig#L118)
  - [root.zig](/workspace/projects/noztr/src/root.zig#L137)
  - [post-audit-improvement-plan.md](/workspace/projects/noztr/docs/plans/post-audit-improvement-plan.md#L143)
- rationale:
  - `nip05_identity.profile_verify_json(...) -> bool` remains an intentional API choice
  - typed parsing and shape failures already happen before the final verify decision; the final
    question is match versus no-match, which is a boolean result
- risk:
  - callers must still route malformed input through the typed parse boundary when they need error
    detail
- reversal trigger:
  - reopen if consumer evidence shows repeated misuse or ambiguity around the boolean verifier shape

- scope:
  - current caller-owned scratch posture on `NIP-05`, `NIP-46`, and `NIP-77`
- rationale:
  - this remains a coherent public ownership contract even though it is not the most Tiger-like
    fixed-capacity shape
  - changing it would be a public API rewrite, not a narrow cleanup
- risk:
  - caller ergonomics remain somewhat heavier than a narrower fixed-capacity return type
- reversal trigger:
  - reopen if SDK use or later remediation proves the accepted ownership shape is materially too
    awkward or inconsistent

- scope:
  - [noztr-sdk-ownership-matrix.md](/workspace/projects/noztr/docs/plans/noztr-sdk-ownership-matrix.md#L73)
- rationale:
  - the `NIP-59` deterministic one-recipient outbound helper remains a clear kernel seam
  - fanout, mailbox policy, delivery orchestration, and session behavior stay explicitly outside
    the kernel
- risk:
  - docs/discovery drift could still teach the wrong entry point
- reversal trigger:
  - reopen if SDK evidence shows one-recipient transcript construction is still too low-level or
    still missing a deterministic kernel primitive

## Residual Risk

- the main API risk is uneven hardening on older direct helpers, not a confused or sprawling public
  facade
- naming and ownership posture remain mostly coherent; the remaining pressure is concentrated in
  helper-level failure semantics and one or two accepted ownership exceptions

## Suggested Remediation Candidates

- targeted fix
  - harden `NIP-86` public helper paths so overlong caller input stays on typed invalid-input
    errors
- targeted fix
  - harden direct `NIP-46` token helpers against caller-controlled assertion leakage
- targeted fix
  - either harden or demote the standalone `NIP-25` reaction classifier helper

## Completion Statement

This angle is complete because:
- the exported facade, shared error layer, accepted ownership exceptions, and the remaining known
  boundary-sensitive helper families were checked directly
- reused prior evidence was named explicitly where it contributed to completion
- the remaining public-contract pressure is now severity-ranked and specific

Reopen this angle if:
- remediation changes the accepted ownership shape materially
- docs/examples evidence shows a broader split-surface contract problem than the current findings
  imply
- new direct public helpers are found to rely on internal invariants before typed validation
