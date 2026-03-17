---
title: Exhaustive Audit Angle 3 Security and Misuse Resistance Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_security_posture
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
  - docs/plans/security-hardening-register.md
  - docs/plans/implemented-nip-audit-report.md
canonical: true
---

# Exhaustive Audit Angle 3: Security / Misuse Resistance

- date: 2026-03-17
- issue: `no-odj`
- packet: `no-ard`
- author: Codex

## Purpose

- evaluate whether public and trust-boundary-facing `noztr` surfaces resist misuse cleanly enough
  for pre-freeze confidence
- focus on invalid-vs-capacity behavior, assertion leaks, hostile-input posture, wrapper sharpness,
  and secret-exposure risk outside the deeper crypto-specific angles
- this angle does not decide cryptographic correctness or backend-wrapper quality in full detail;
  those remain dedicated later angles

## Scope

Reviewed directly in this pass:
- `docs/plans/security-hardening-register.md`
- `docs/plans/implemented-nip-audit-report.md`
- `src/nip42_auth.zig`
- `src/nip44.zig`
- `src/nip46_remote_signing.zig`
- `src/nip59_wrap.zig`
- `src/nip86_relay_management.zig`
- `src/nip98_http_auth.zig`
- `src/nip25_reactions.zig`
- `src/internal/relay_origin.zig`
- hostile example routing in `examples/README.md`

Explicit exclusions:
- full crypto/backend seam quality review
- performance review
- fresh file-by-file re-audit of every implemented module

## Standards

- `docs/plans/audit-angle-standards.md`
  - misuse-prone public entry points
  - trust-boundary wrappers
  - invalid-vs-capacity behavior
  - assertion leaks
  - hostile input posture
  - secret exposure risks outside deep crypto correctness
- repo hardening defaults already recorded in `docs/plans/security-hardening-register.md`

## Evidence Sources

Primary:
- `docs/plans/security-hardening-register.md`
- reviewed public wrapper modules listed in scope

Secondary:
- hostile example coverage indexed in `examples/README.md`

## Coverage

Explicitly checked:
- current hardening owners for auth, PoW, delete, transcript, and parser/lifetime safety
- newer split trust-boundary surfaces with hostile examples:
  - `NIP-42`
  - `NIP-46`
  - `NIP-59`
  - `NIP-86`
  - `NIP-98`
- direct public token/helper functions that are easy to misuse outside the higher safe wrappers
- whether public invalid input still reaches debug assertions on representative older surfaces
- whether the internal `relay_origin` primitive is leaking collapsed failure semantics across the
  public boundary

Explicitly not checked:
- backend cryptographic seam quality in depth
- secret wiping completeness across all crypto-bearing code paths
- every implemented module source file

Matrix rows touched:
- `Build and packaging surface`: `not applicable`
- `Exported facade and shared support`: `complete`
- `Event/message/filter/key core`: `complete`
- `Implemented NIP surfaces in docs/plans/implemented-nip-audit-report.md`: `complete`
- `Cryptography-bearing protocol consumers`: `complete`
- `Internal helpers affecting release confidence`: `complete`
- `Public error-contract and invalid-vs-capacity families`: `complete`
- `Examples and discovery surface`: `complete`
- `Freeze-critical control and audit docs`: `not applicable`

## Findings

### Public-path assertion leaks remain in NIP-86 admin JSON-RPC trust boundaries

- severity: `high`
- scope:
  - [nip86_relay_management.zig](/workspace/projects/noztr/src/nip86_relay_management.zig#L84)
  - [nip86_relay_management.zig](/workspace/projects/noztr/src/nip86_relay_management.zig#L146)
  - [nip86_relay_management.zig](/workspace/projects/noztr/src/nip86_relay_management.zig#L173)
- why it matters:
  - `method_parse(...)`, `request_parse_json(...)`, and `response_parse_json(...)` are public
    trust-boundary entry points
  - overlong hostile input can still hit debug assertions instead of returning typed
    `InvalidMethod`, `InvalidRequest`, or `InvalidResponse`
- evidence:
  - `method_parse(...)` asserts `text.len <= limits.tag_item_bytes_max` before runtime rejection
  - request/response parse paths assert `input.len <= limits.relay_message_bytes_max` before
    runtime invalid-input mapping
- remediation pressure:
  - targeted fix

### Direct NIP-46 token helpers still rely on size assertions for caller-controlled input

- severity: `medium`
- scope:
  - [nip46_remote_signing.zig](/workspace/projects/noztr/src/nip46_remote_signing.zig#L184)
  - [nip46_remote_signing.zig](/workspace/projects/noztr/src/nip46_remote_signing.zig#L217)
- why it matters:
  - the broader `NIP-46` public message and URI surfaces were hardened already
  - these direct helpers remain public and can still abort on overlong misuse instead of returning
    typed `InvalidMethod` or `InvalidPermission`
- evidence:
  - `method_parse(...)` and `permission_parse(...)` assert bounded input length rather than
    guarding it at runtime
- remediation pressure:
  - targeted fix

### NIP-25 exposes a misuse-prone public classifier with UTF-8 assertion semantics

- severity: `low`
- scope:
  - [nip25_reactions.zig](/workspace/projects/noztr/src/nip25_reactions.zig#L59)
- why it matters:
  - `reaction_classify_content(...)` is a public helper
  - it asserts UTF-8 instead of rejecting or avoiding misuse explicitly
- evidence:
  - the function is safe when reached through `reaction_parse(...)`, but not inherently safe as a
    direct public helper
- remediation pressure:
  - targeted fix

## Accepted Exceptions

- scope:
  - [relay_origin.zig](/workspace/projects/noztr/src/internal/relay_origin.zig#L9)
- rationale:
  - `parse_websocket_origin(...) -> ?WebsocketOrigin` remains an internal primitive
  - public callers such as `NIP-42`, `NIP-46`, and `NIP-37` already map failure into their own
    typed public errors
- risk:
  - internal callers must continue preserving typed mapping at the boundary
- reversal trigger:
  - reopen if a public surface starts exposing `null`-collapsed failure semantics directly

- scope:
  - hostile example posture on boundary-heavy surfaces
- rationale:
  - adversarial examples are present for the main misuse-prone split surfaces
- risk:
  - coverage can still lag on older, smaller helpers
- reversal trigger:
  - reopen if later angles show a public misuse-prone surface without comparable hostile examples

## Residual Risk

- newer requested-loop and boundary-validation surfaces are better hardened than some older public
  helper APIs
- the main risk from this angle is uneven hardening rather than systemic insecurity
- crypto-specific trust still depends on the later cryptographic-correctness and
  backend-wrapper-quality angles

## Suggested Remediation Candidates

- targeted fix
  - harden public `NIP-86` admin parse/method helpers so overlong hostile input stays on typed
    invalid-input paths
- targeted fix
  - harden public `NIP-46` direct token helpers against overlong misuse
- targeted fix
  - decide whether `reaction_classify_content(...)` should become misuse-safe or be demoted from the
    public surface

## Completion Statement

This angle is complete because:
- the major trust-boundary hardening owners were rechecked
- representative boundary-heavy split surfaces were rechecked directly
- the main remaining misuse defects are now explicit and severity-ranked

Reopen this angle if:
- later crypto angles show secret-exposure or trust-boundary findings that materially alter this
  posture
- new evidence shows additional public assertion leaks outside the currently named findings
