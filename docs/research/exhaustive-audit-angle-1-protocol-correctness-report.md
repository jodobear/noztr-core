---
title: Exhaustive Audit Angle 1 Protocol Correctness Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_protocol_correctness_findings
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
  - docs/plans/implemented-nip-audit-report.md
canonical: true
---

# Exhaustive Audit Angle 1: Protocol Correctness

- date: 2026-03-17
- issue: `no-3ib`
- packet: `no-ard`
- author: Codex

## Purpose

- prove or falsify that `noztr`'s implemented protocol surface still matches its accepted contract
  after the requested-NIP loop, SDK-informed boundary-validation work, and the later audit
  follow-ups
- verify that core canonicalization, parse/build symmetry, and explicit unsupported boundaries
  remain intact on the current codebase
- this angle does not cover security posture, parity quality, crypto-wrapper quality, performance,
  or docs-teaching quality except where those directly affect protocol correctness

## Scope

Reviewed directly in this pass:
- `src/root.zig`
- `src/errors.zig`
- `src/limits.zig`
- `src/nip01_event.zig`
- `src/nip01_filter.zig`
- `src/nip01_message.zig`
- `src/nostr_keys.zig`
- `src/nip13_pow.zig`
- `src/nip19_bech32.zig`
- `src/nip21_uri.zig`

Reused as canonical primary correctness evidence:
- `docs/plans/implemented-nip-audit-report.md`

Explicit exclusions for this angle:
- fresh line-by-line re-audit of every implemented NIP source file
- performance and memory review
- crypto/backend-wrapper sharpness review
- docs/example correctness beyond discovery of obvious protocol drift

## Standards

- `docs/plans/audit-angle-standards.md`
  - implemented NIP behavior against the accepted contract
  - parser/builder symmetry where applicable
  - canonicalization and normalization behavior
  - explicit unsupported and non-goal boundaries
- canonical implemented-NIP evidence is acceptable for a `complete` status when it is still the
  owning correctness artifact and this pass finds no contrary evidence in the shared core

## Evidence Sources

Primary:
- local core code in the reviewed source files
- co-located tests in those source files
- `docs/plans/implemented-nip-audit-report.md`

Secondary:
- current active control docs for scope/routing:
  - `docs/plans/build-plan.md`
  - `docs/plans/phase-h-remaining-work.md`
  - `docs/plans/exhaustive-pre-freeze-audit.md`

Weak / not used as protocol authority:
- prior reference-library parity conclusions already absorbed into
  `docs/plans/implemented-nip-audit-report.md`

## Coverage

Explicitly checked:
- exported facade still reflects the implemented surface without obvious stale or missing protocol
  exports
- shared limit and error families still line up with the strict protocol-core contract
- core event logic still separates:
  - full object JSON parsing
  - canonical ID-preimage serialization
  - full object JSON serialization
  - unsigned full object JSON serialization
- event tests still cover:
  - parse/serialize symmetry
  - canonical id verification
  - oversized shape rejection
  - invalid UTF-8 rejection
  - public `BufferTooSmall` behavior on serializer paths
- filter core still preserves accepted lowercase-prefix matching plus accepted uppercase single-tag
  `#X` behavior
- message core still preserves strict command arity, strict relay `OK` status-prefix behavior, and
  deterministic transcript transitions
- NIP-13, NIP-19, and NIP-21 core helpers still expose the accepted strict correctness boundaries
- canonical implemented-NIP audit report still covers the implemented NIP set and the requested-loop
  supplement without contrary evidence from the reviewed shared core

Explicitly not checked:
- fresh per-file source re-review of every implemented NIP module
- build and packaging artifacts for protocol correctness
- internal helper modules that are better judged under later security, crypto, Zig, API, or docs
  angles
- non-implemented helper modules not owned by the canonical implemented-NIP correctness artifact

Matrix rows touched:
- `Build and packaging surface`: `not applicable`
- `Exported facade and shared support`: `complete`
- `Event/message/filter/key core`: `complete`
- `Implemented NIP surfaces in docs/plans/implemented-nip-audit-report.md`: `complete`
- `Cryptography-bearing protocol consumers`: `complete`
- `Freeze-critical control and audit docs`: `not applicable`

## Findings

- none

No new protocol-correctness defect was found in this angle. The reviewed shared core still matches
the accepted contract, and the canonical implemented-NIP audit artifact remains sufficient as the
owning correctness evidence for the implemented NIP set.

## Accepted Exceptions

- scope: implemented NIP correctness evidence is partly reused from
  `docs/plans/implemented-nip-audit-report.md` rather than regenerated from a new file-by-file
  source pass
- rationale: that report is already the canonical owning correctness artifact for the implemented
  surfaces, including the requested-loop supplement and the later maintenance supplement; this pass
  revalidated the shared core and found no contrary evidence
- risk: a correctness issue confined to one leaf implemented-NIP module could still be missed if it
  was not already captured in the canonical report
- reversal trigger: reopen this angle if a later audit angle or SDK/parity evidence finds a
  correctness defect in an implemented-NIP leaf module that was not already reflected in the
  canonical audit artifact

## Residual Risk

- this angle is strong on shared-core correctness and on explicit implemented-NIP coverage
  accounting, but it is not a fresh source-by-source replay of every implemented module
- correctness confidence for many leaf NIPs therefore still depends on the integrity of
  `docs/plans/implemented-nip-audit-report.md` as the canonical owning artifact

## Suggested Remediation Candidates

- none

## Completion Statement

This angle is complete because:
- the implemented NIP set has an explicit owning correctness artifact
- the shared event/filter/message/key/PoW/bech32/URI core was rechecked directly
- no contrary evidence was found that would invalidate the current accepted correctness posture

Reopen this angle if:
- a later audit angle finds a concrete protocol-correctness defect
- SDK or parity evidence contradicts the canonical implemented-NIP correctness report
- a code change materially alters core canonicalization, parser/builder symmetry, or explicit
  unsupported boundaries
