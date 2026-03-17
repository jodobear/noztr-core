---
title: Exhaustive Audit Angle 2 Parity and Interoperability Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_interoperability_posture
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
  - docs/plans/implemented-nip-audit-report.md
  - docs/release/intentional-divergences.md
  - docs/archive/plans/phase-f-parity-matrix.md
  - docs/archive/plans/phase-f-parity-ledger.md
canonical: true
---

# Exhaustive Audit Angle 2: Ecosystem Parity / Interoperability

- date: 2026-03-17
- issue: `no-f2u`
- packet: `no-ard`
- author: Codex

## Purpose

- prove or falsify that `noztr`'s current public protocol surface remains interoperable enough for
  its strict kernel goals
- verify that current divergences are intentional, bounded, and still justified against the active
  production parity lane and available secondary ecosystem evidence
- this angle does not decide security, crypto, performance, or rewrite posture on its own except
  where interoperability evidence clearly pressures those outcomes

## Scope

Reviewed directly in this pass:
- `docs/plans/implemented-nip-audit-report.md`
- `docs/release/intentional-divergences.md`
- `docs/archive/plans/phase-f-parity-matrix.md`
- `docs/archive/plans/phase-f-parity-ledger.md`
- `docs/archive/plans/phase-f-risk-burndown.md`

Secondary context read:
- `docs/research/rust-nostr-study.md`
- `docs/research/applesauce-study.md`
- `docs/research/libnostr-z-comparison-report.md`

Explicit exclusions for this angle:
- fresh execution of interop harnesses
- fresh source-by-source parity comparison against every reference library
- docs-teaching quality except where stale docs would distort interoperability claims

## Standards

- `docs/plans/audit-angle-standards.md`
  - active production parity lane: `rust-nostr`
  - secondary ecosystem signals where relevant: `nostr-tools`, applesauce, or spec-first fallback
  - every implemented NIP surface must have an explicit interoperability status
  - evidence classes must be named per surface: strong, secondary, weak, or unavailable
- parity is judged against `noztr`'s accepted deterministic-and-compatible Layer 1 posture, not by
  raw mimicry of the most permissive library behavior

## Evidence Sources

Primary:
- `docs/plans/implemented-nip-audit-report.md`
- `docs/release/intentional-divergences.md`
- `docs/archive/plans/phase-f-parity-matrix.md`
- `docs/archive/plans/phase-f-parity-ledger.md`
- `docs/archive/plans/phase-f-risk-burndown.md`

Secondary:
- `docs/research/rust-nostr-study.md`
- `docs/research/applesauce-study.md`
- `docs/research/libnostr-z-comparison-report.md`

Weak:
- older archived TypeScript parity evidence retained only as historical signal

## Coverage

Explicitly checked:
- the active parity model is still coherent:
  - `rust-nostr` is the active production lane
  - `nostr-tools` remains archived secondary evidence
- the implemented-NIP audit still names evidence class per implemented surface:
  - `HARNESS_COVERED`
  - `SOURCE_REVIEW_ONLY`
  - `LIB_UNSUPPORTED`
  - `NOT_COVERED_IN_THIS_PASS`
- the current divergence set is still intentional and bounded rather than accidental drift
- archived Phase F parity artifacts still support the current active-lane story rather than
  contradicting it
- requested-loop and later split surfaces are represented in the canonical implemented-NIP audit
  with explicit evidence-strength language rather than being silently treated as if they had deep
  parity coverage

Explicitly not checked:
- rerunning `rust-nostr` or historical TypeScript harnesses in this angle
- exhaustive applesauce-by-surface compatibility review
- external runtime/service interoperability beyond the protocol-helper boundary

Matrix rows touched:
- `Build and packaging surface`: `not applicable`
- `Exported facade and shared support`: `not applicable`
- `Event/message/filter/key core`: `complete`
- `Implemented NIP surfaces in docs/plans/implemented-nip-audit-report.md`: `complete`
- `Cryptography-bearing protocol consumers`: `complete`
- `Freeze-critical control and audit docs`: `not applicable`

## Findings

- none

No new interoperability blocker was found in this angle. The current parity posture remains honest:
- strong active rust evidence where overlap exists
- weaker source/spec-first evidence where dedicated library support is unavailable
- explicit intentional divergences where strict Layer 1 behavior remains justified

## Accepted Exceptions

- scope: interoperability evidence quality is uneven across the implemented surface
- rationale:
  - the repo already records that some implemented NIPs have only `SOURCE_REVIEW_ONLY`,
    `LIB_UNSUPPORTED`, or `NOT_COVERED_IN_THIS_PASS` evidence classes
  - the current audit posture is honest about that unevenness instead of flattening all surfaces
    into one fake parity score
- risk:
  - weaker-evidence surfaces may still hide ecosystem friction that strong harness overlap would
    have exposed earlier
- reversal trigger:
  - reopen this angle if SDK, reference-library, or ecosystem integration work surfaces concrete
    incompatibility on a currently weak-evidence surface

- scope: `nostr-tools` historical parity evidence remains archived rather than actively rerun
- rationale:
  - the current repo policy intentionally keeps rust as the gating lane and TypeScript as historical
    secondary evidence
- risk:
  - drift against current JavaScript ecosystem behavior may go unnoticed longer on surfaces where
    Rust overlap is weak
- reversal trigger:
  - reopen this angle if JS ecosystem pressure becomes release-relevant for a specific surface

## Residual Risk

- interoperability confidence is strongest for the original deep rust parity set and weaker for
  later requested-loop and spec-first surfaces
- this is acceptable for the current strict kernel posture because the evidence-strength gradient is
  documented, but it remains real residual risk rather than a clean parity sweep

## Suggested Remediation Candidates

- targeted fix
  - if post-audit meta-analysis decides the weaker-evidence surfaces need stronger release
    confidence, open bounded parity-expansion lanes for the highest-risk weak-evidence modules

## Completion Statement

This angle is complete because:
- every implemented surface already has an explicit interoperability status in the canonical audit
  artifact
- the repo’s active and archived parity owners still agree on the current lane model
- no new evidence in this pass contradicts the current intentional-divergence posture

Reopen this angle if:
- a later audit angle finds a correctness/security/API issue that changes interoperability claims
- SDK or ecosystem integration finds concrete friction on a currently weak-evidence surface
- the active parity lane policy changes
