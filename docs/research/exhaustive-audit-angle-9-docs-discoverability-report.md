---
title: Exhaustive Audit Angle 9 Docs Discoverability Report
doc_type: report
status: active
owner: noztr
phase: phase-h
read_when:
  - reviewing_exhaustive_audit_angle_results
  - evaluating_docs_discoverability
depends_on:
  - docs/plans/exhaustive-pre-freeze-audit.md
  - docs/plans/exhaustive-pre-freeze-audit-matrix.md
  - docs/plans/audit-angle-standards.md
canonical: true
---

# Exhaustive Audit Angle 9: Docs / Examples / Discoverability

- date: 2026-03-17
- issue: `no-l5h7`
- packet: `no-ard`
- author: Codex

## Purpose

- evaluate whether the public teaching and discovery surface is accurate enough for freeze
  confidence
- focus on example contract-layer correctness, hostile-example coverage, discovery routing, and the
  truthfulness of current active state docs
- this angle does not fix stale teaching surfaces; it records them for post-audit remediation

## Scope

Reviewed directly in this pass:
- `README.md`
- `examples/README.md`
- `examples/nip59_example.zig`
- `examples/nip17_wrap_recipe.zig`
- `examples/nip05_example.zig`
- `examples/discovery_recipe.zig`
- `handoff.md`
- `docs/README.md`
- `docs/plans/build-plan.md`
- `docs/plans/phase-h-remaining-work.md`
- `docs/plans/exhaustive-pre-freeze-audit.md`
- `docs/plans/noztr-sdk-ownership-matrix.md`

Explicit exclusions:
- implementation correctness beyond what the teaching surface claims
- remediation edits to stale public docs or examples

## Standards

- `docs/plans/audit-angle-standards.md`
  - examples teach the right contract layer
  - hostile examples exist where needed
  - discovery docs route correctly
  - active audit/state docs tell the truth about current work
  - freeze-critical docs are not stale or contradictory

## Evidence Sources

Primary:
- local docs and example files listed in scope

Secondary:
- accepted split-boundary guidance in `docs/plans/noztr-sdk-ownership-matrix.md`
- current active-state routing in `handoff.md`, `docs/plans/build-plan.md`, and
  `docs/plans/phase-h-remaining-work.md`

## Coverage

Explicitly checked:
- examples index claims for `NIP-59`, `NIP-05`, and discovery-oriented entry points
- current root `README.md` routing against actual active Phase H state
- current control-surface docs for contradiction against the active packet and audit program
- whether boundary-heavy identity lookup currently has a hostile example comparable to other split
  or misuse-prone surfaces

Explicitly not checked:
- every legacy archival doc
- external website or package-registry discoverability

Matrix rows touched:
- `Build and packaging surface`: `not applicable`
- `Examples and discovery surface`: `complete`
- `Freeze-critical control and audit docs`: `complete`

## Findings

### Examples index routes the deterministic NIP-59 outbound path to the wrong primary entry point

- severity: `medium`
- scope:
  - [examples/README.md](/workspace/projects/noztr/examples/README.md#L142)
  - [nip59_example.zig](/workspace/projects/noztr/examples/nip59_example.zig#L1)
  - [nip17_wrap_recipe.zig](/workspace/projects/noztr/examples/nip17_wrap_recipe.zig#L1)
  - [noztr-sdk-ownership-matrix.md](/workspace/projects/noztr/docs/plans/noztr-sdk-ownership-matrix.md#L73)
- why it matters:
  - the direct `nip59_example.zig` file only shows a typed invalid-wrap boundary failure
  - the successful deterministic outbound transcript construction lives in
    `nip17_wrap_recipe.zig`
  - readers following the current examples index can open the wrong file and miss the actual
    accepted kernel seam
- evidence:
  - `examples/README.md` currently presents `nip59_example.zig` as the direct reference example
    while the ownership matrix and recipe demonstrate the successful outbound path elsewhere
- remediation pressure:
  - targeted fix

### NIP-05 still lacks a hostile consumer-facing example despite remaining a boundary-heavy lookup surface

- severity: `medium`
- scope:
  - [examples/README.md](/workspace/projects/noztr/examples/README.md#L48)
  - [examples/README.md](/workspace/projects/noztr/examples/README.md#L109)
  - [nip05_example.zig](/workspace/projects/noztr/examples/nip05_example.zig#L1)
  - [discovery_recipe.zig](/workspace/projects/noztr/examples/discovery_recipe.zig#L1)
- why it matters:
  - `NIP-05` is still a public lookup and verification boundary with real misuse potential
  - the repo now expects hostile examples by default for SDK-facing or boundary-heavy surfaces
  - identity-proof flows have hostile coverage, but the direct `NIP-05` surface does not
- evidence:
  - there is a direct `nip05_example.zig`
  - there is no `nip05_adversarial_example.zig` or equivalent hostile fixture in `examples/`
- remediation pressure:
  - targeted fix

### The root README still routes readers toward completed packets instead of the current exhaustive-audit state

- severity: `medium`
- scope:
  - [README.md](/workspace/projects/noztr/README.md#L16)
  - [README.md](/workspace/projects/noztr/README.md#L30)
  - [README.md](/workspace/projects/noztr/README.md#L99)
  - [handoff.md](/workspace/projects/noztr/handoff.md#L36)
  - [build-plan.md](/workspace/projects/noztr/docs/plans/build-plan.md#L105)
  - [phase-h-remaining-work.md](/workspace/projects/noztr/docs/plans/phase-h-remaining-work.md#L76)
- why it matters:
  - internal startup routing is now correct through `AGENTS.md`, `handoff.md`, and `docs/README.md`
  - the public root README still advertises the older requested-NIP / Phase H packets as the
    current path
  - that is a real discoverability drift and weakens freeze confidence for new readers
- evidence:
  - README still names `phase-h-kickoff`, `phase-h-additional-nips-plan`, `phase-h-wave1-loop`,
    and the requested-NIP loop as current planning/execution focus
  - active control docs now point to the exhaustive audit and current Phase H packet instead
- remediation pressure:
  - targeted fix

## Accepted Exceptions

- scope:
  - [handoff.md](/workspace/projects/noztr/handoff.md#L1)
  - [docs/README.md](/workspace/projects/noztr/docs/README.md#L1)
  - [build-plan.md](/workspace/projects/noztr/docs/plans/build-plan.md#L1)
  - [phase-h-remaining-work.md](/workspace/projects/noztr/docs/plans/phase-h-remaining-work.md#L1)
- rationale:
  - the internal control surface is still coherent and truthful even though the external root
    README lags
  - that means the problem is discoverability drift, not an active-state control-surface collapse
- risk:
  - external readers can still form the wrong picture from the root README alone
- reversal trigger:
  - reopen if active control docs themselves begin to drift or contradict one another again

- scope:
  - current `NIP-59` split teaching posture
- rationale:
  - the actual accepted contract is still available and correct in `nip17_wrap_recipe.zig`,
    `nip59_adversarial_example.zig`, and the ownership matrix
  - the current problem is index routing, not missing underlying teaching material
- risk:
  - readers can still miss the right example unless the index is corrected
- reversal trigger:
  - reopen if later docs changes blur the one-recipient outbound seam itself

## Residual Risk

- the docs surface is not chaotic, but it still has enough discovery drift to undermine freeze
  confidence if left as-is
- the main risk is reader misrouting and under-taught hostile boundary behavior, not false protocol
  claims in the canonical control docs

## Suggested Remediation Candidates

- targeted fix
  - route the `NIP-59` successful deterministic outbound path to `nip17_wrap_recipe.zig` in the
    examples index
- targeted fix
  - add a hostile `NIP-05` example fixture and index it
- targeted fix
  - refresh the root `README.md` so it reflects the current Phase H / exhaustive-audit posture

## Completion Statement

This angle is complete because:
- the main discovery docs, examples index, and freeze-critical control docs were checked directly
- the remaining drift is now concrete, severity-ranked, and scoped
- the report distinguishes internal control-surface truth from external discoverability lag

Reopen this angle if:
- remediation changes the current examples/discovery routing materially
- later evidence shows a broader mismatch between examples and accepted kernel boundaries
