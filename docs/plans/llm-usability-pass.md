---
title: LLM Usability Pass
doc_type: log
status: closed
owner: noztr
phase: phase-h
read_when:
  - executing_oq_e_006
  - tracing_phase_h_remaining_work
  - evaluating_rc_usability_defaults
depends_on:
  - docs/plans/build-plan.md
  - docs/plans/decision-index.md
canonical: true
---

# LLM Usability Pass (OQ-E-006)

Date: 2026-03-16

Status: closed

Purpose: evaluate hardened v1 APIs from an LLM-first integration workflow before RC API freeze.

Decision linkage: this pass is closed and is now one input into the next Phase H boundary-validation
packet before any RC API-freeze claim.

## Scope Snapshot

- In scope: implemented strict-default modules in `src/` (`nip01_event`, `nip01_filter`,
  `nip01_message`, `nip42_auth`, `nip70_protected`, `nip11`, `nip09_delete`, `nip40_expire`,
  `nip13_pow`) and implemented I4 modules (`nip19_bech32`, `nip21_uri`, `nip02_contacts`,
  `nip65_relays`) plus root exports in `src/root.zig`.
- In scope: contract/doc parity on currently shipped signatures, typed errors, and strict transcript
  semantics.
- In scope: trust-boundary wrapper ergonomics (`pow_meets_difficulty_verified_id`,
  `delete_extract_targets_checked`, transcript marker/apply functions).
- In scope: canonical transcript path clarity (`transcript_mark_client_req` +
  `transcript_apply_relay`) and canonical-only unreleased API wording.
- Out of scope: transport/runtime integration helpers, post-RC API redesign.

## Task Battery

- T1 `event lifecycle`: parse -> canonical serialize -> compute id -> verify split/full paths.
- T2 `filter matching`: parse multi-field filters and evaluate deterministic OR-of-filters behavior.
- T3 `message grammar`: parse/serialize REQ and COUNT with multiple filters; enforce strict relay
  grammar (`OK` lowercase hex id, prefixed status).
- T4 `transcript flow`: apply `transcript_mark_client_req` then relay transitions for
  `EVENT* -> EOSE -> CLOSED` and `REQ -> CLOSED` early-close branch.
- T5 `auth/protected`: validate strict challenge/relay/timestamp checks and protected-event policy
  coupling.
- T6 `policy wrappers`: validate canonical checked wrappers for PoW/delete trust-boundary call sites.

## Rubric

- `R1 discoverability`: can an LLM locate the correct strict API and wrapper entry points from names
  and exported surfaces without trial-and-error.
- `R2 boundary clarity`: typed errors communicate trust-boundary causes precisely enough for policy
  handling.
- `R3 composition cost`: common relay/client workflows require low ceremony while keeping strict
  defaults explicit.
- `R4 misuse resistance`: unsafe or ambiguous paths are difficult to pick accidentally.
- `R5 docs parity`: planning artifacts match implemented signatures and semantics.

Scoring scale per rubric item:

- `2`: good (clear with no notable friction)
- `1`: acceptable (minor friction)
- `0`: poor (repeated confusion or unsafe default tendency)

Pass threshold:

- No `0` on `R2` or `R4`.
- Average score >= `1.4` across `R1`..`R5` for the first full battery run.

## Execution Run: 2026-03-16

Micro-freeze:

- Scope:
  - execute the `T1`..`T6` battery against the current strict-default API surface
  - repair teaching-surface gaps in examples and example routing only
- Non-goals:
  - no kernel behavior change
  - no new strictness-default change
  - no SDK-side workflow expansion
- Accepted valid input versus canonical emitted output:
  - teach canonical event serialization and checked id/signature flow
  - teach strict default message grammar through `nip01_message`
  - teach canonical transcript flow as `transcript_mark_client_req` then `transcript_apply_relay`
  - teach checked wrapper entry points as the default trust-boundary surface
- Invalid-vs-capacity matrix:
  - this slice adds no new public builder or validator
  - no invalid-vs-capacity mapping changed in code or docs
- Sync touchpoints:
  - `examples/nip01_example.zig`
  - `examples/nip42_example.zig`
  - `examples/strict_core_recipe.zig`
  - `examples/examples.zig`
  - `examples/README.md`
  - `docs/plans/security-hardening-register.md`
  - `docs/plans/build-plan.md`
  - `docs/plans/phase-h-remaining-work.md`
  - `docs/plans/decision-index.md`
  - `docs/plans/decision-log.md`
  - `handoff.md`

Battery results:

- `T1` pass:
  - `examples/nip01_example.zig` now teaches canonical serialize -> parse -> checked id -> verify
- `T2` pass:
  - `examples/strict_core_recipe.zig` now teaches multi-filter parsing and deterministic
    `filters_match_event` behavior
- `T3` pass:
  - `examples/strict_core_recipe.zig` now teaches strict `REQ`, `COUNT`, and relay `OK` grammar
    through `nip01_message`
- `T4` pass:
  - `examples/strict_core_recipe.zig` now teaches canonical transcript ordering, including early
    `REQ -> CLOSED`
- `T5` pass:
  - `examples/nip42_example.zig` now teaches `auth_validate_event`, `auth_state_accept_event`, and
    protected-event policy coupling with `nip70_protected`
- `T6` pass:
  - `examples/strict_core_recipe.zig`, `examples/nip13_example.zig`, and `examples/nip09_example.zig`
    together teach the checked wrapper defaults

Usability findings from the executed battery:

- `F1` fixed:
  - there was no single obvious strict-core example for a cold reader crossing event, message,
    transcript, and checked wrapper paths
- `F2` fixed:
  - `nip01_example.zig` was too thin for the actual canonical event lifecycle
- `F3` fixed:
  - `nip42_example.zig` did not show the validated auth path or protected-event coupling
- `F4` accepted low:
  - transcript and auth flows still require callers to compose multiple kernel modules directly, but
    the composition is now taught explicitly and stays inside deterministic kernel ownership
- `F5` reviewed with no fix needed:
  - `src/root.zig` export names and `docs/plans/v1-api-contracts.md` naming are aligned

Rubric result:

- `R1 discoverability`: `2`
- `R2 boundary clarity`: `2`
- `R3 composition cost`: `1`
- `R4 misuse resistance`: `2`
- `R5 docs parity`: `2`
- Average: `1.8`

Pass outcome:

- threshold met
- no `0` on `R2` or `R4`
- no remaining Medium+ usability blocker

Canonical transcript reminder:

```text
REQ marked -> EVENT* -> EOSE? -> EVENT* -> CLOSED?
REQ marked -> CLOSED
```

## Strictness Profile Decision Inputs (Current)

- Keep these currently strict behaviors as carried-forward RC freeze inputs:
  - filter `ids`/`authors` lowercase hex-prefix semantics (`1..64`).
  - unknown filter-field rejection.
  - relay `OK` status-prefix strictness.
  - NIP-42 origin strictness (normalized path binding and `ws`/`wss` distinction).
- Current hygiene baseline for usability runs: Tiger hard checks are clean in `src/` (`>100` columns none,
  `>70`-line functions none); strict-width and anti-pattern cleanup remains a quality follow-up where
  applicable.

## OQ-E-006 Closure Criteria

`OQ-E-006` is closed only when all criteria below are complete:

- C1 task battery executed end-to-end at least once against current implementation and docs.
- C2 rubric pass threshold met (`R2`/`R4` non-zero; average >= `1.4`).
- C3 all Medium+ usability blockers identified in the battery are either fixed or explicitly accepted
  with owner + reversal trigger.
- C4 `docs/plans/v1-api-contracts.md`, `docs/plans/build-plan.md`, `docs/plans/decision-log.md`,
  `docs/plans/security-hardening-register.md`, and `handoff.md` reflect the same usability status.
- C5 decision-log entry records closure state transition for `OQ-E-006` before RC API freeze.

Closure result:

- satisfied on `2026-03-16`

## Decisions

- `UL-001`: treat this artifact as the canonical execution log for usability pass status and closure
  criteria.
- `UL-002`: run usability evaluation on hardened strict APIs only (post-security checkpoint sequence).
- `UL-003`: close `OQ-E-006` with teaching-surface fixes only; no kernel-behavior rollback or
  strictness downgrade was required by the battery.

## Tradeoffs

## Tradeoff T-UL-001: Immediate usability feedback versus post-hardening stability

- Context: usability testing can begin earlier on evolving APIs or after hardening stabilizes.
- Options:
  - O1: start before hardening completion.
  - O2: start after hardening completion.
- Decision: O2.
- Benefits: lower churn and more reliable UX signal for release-facing APIs.
- Costs: later feedback on pre-hardening ergonomics.
- Risks: remaining usability issues may cluster close to RC freeze.
- Mitigations: run focused task battery now and track closure criteria explicitly.
- Reversal Trigger: security follow-up reopens major API surfaces and invalidates current run.
- Principles Impacted: P01, P03, P05.
- Scope Impacted: OQ-E-006 closure workflow and release readiness checks.

## Open Questions

- none in this artifact; next work is the SDK-informed boundary-validation slice in
  `docs/plans/phase-h-remaining-work.md`

## Principles Compliance

- Required sections present: `Decisions`, `Tradeoffs`, `Open Questions`, `Principles Compliance`.
- `P01`: trust-boundary wrappers and typed failures are explicitly evaluated.
- `P02`: scope remains protocol-kernel APIs and avoids transport-coupled UX assumptions.
- `P03`: parity drift checks are explicit in task battery and findings, and no contract drift remains
  open after the closure run.
- `P04`: relay/auth/protected policy usability is included as a dedicated battery task.
- `P05`: deterministic transcript and grammar semantics are explicitly tested.
- `P06`: evaluation focuses on bounded strict APIs and does not introduce unbounded runtime behavior.
