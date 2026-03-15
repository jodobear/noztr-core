---
title: Build Plan History
doc_type: archive
status: archived
owner: noztr
archive_of: docs/plans/build-plan.md
read_when:
  - tracing_old_build_plan_sections
  - reconstructing_phase_e_to_phase_h_execution_history
---

# Build Plan History

This archive preserves the historical execution detail that was removed from the active
`docs/plans/build-plan.md` on 2026-03-15 to keep the build plan baseline-oriented.

Use the active build plan for current execution state. Use this archive only when historical
reconstruction or traceability is required.

## Archived Execution Snapshot

The pre-trim build plan carried these historical state details directly:

- I0-I7 were complete and validated under `zig build test --summary all` and `zig build`
- I4 optional modules remained implemented with non-interference coverage
- I5 and I6 gate notes recorded staged crypto / extension validation outcomes
- I7 closure evidence pointed to:
  - `docs/archive/plans/i7-regression-evidence.md`
  - `docs/archive/plans/i7-api-contract-trace-checklist.md`
  - `docs/archive/plans/i7-phase-f-kickoff-handoff.md`
- Phase F kickoff, replay burn-down, parity matrix, and parity ledger were tracked under
  `docs/archive/plans/phase-f-*.md`
- Phase G local-only release-readiness closure was complete, while remote readiness remained
  deferred-by-operator
- Phase H kickoff, Wave 1, Wave 2 / `NIP-46`, Wave 3 / `NIP-06`, the post-Wave `NIP-51`
  private-list follow-up, and the requested-NIP loop up through `NIP-47` were all recorded inline

The active build plan now keeps only the current baseline and routes detailed historical material
to archive, handoff, and the current Phase H packet docs.

## Archived Phase Schedule Snapshot

The pre-trim build plan preserved a detailed phase/module schedule:

- `I0`
  - foundation and shared contracts
  - `src/root.zig`, `src/limits.zig`, `src/errors.zig`, build/test wiring
- `I1`
  - core event and filter kernel
  - `src/nip01_event.zig`, `src/nip01_filter.zig`
- `I2`
  - message grammar, auth/protected, and relay-info core
  - `src/nip01_message.zig`, `src/nip42_auth.zig`, `src/nip70_protected.zig`, `src/nip11.zig`
- `I3`
  - lifecycle policy primitives
  - `src/nip09_delete.zig`, `src/nip40_expire.zig`, `src/nip13_pow.zig`
- `I4`
  - optional identity and relay metadata codecs
  - `src/nip19_bech32.zig`, `src/nip21_uri.zig`, `src/nip02_contacts.zig`,
    `src/nip65_relays.zig`
- `I5`
  - core private messaging crypto and wrap
  - `src/nip44.zig`, `src/nip59_wrap.zig`
- `I6`
  - optional extension message lane
  - `src/nip45_count.zig`, `src/nip50_search.zig`, `src/nip77_negentropy.zig`
- `I7`
  - hardening, conformance sweep, and release-candidate handoff
  - all implemented v1 modules

The schedule itself is historical. Current execution sequencing is now carried by the active build
plan and the active Phase H packet docs.

## Archived Governance And Gate Snapshot

The pre-trim build plan also carried historical governance detail inline:

- implemented-NIP audit execution rules
- robustness / real-world validation execution rules
- post-kernel requested-NIP execution rules
- Phase F hard-gate closure status for epic `no-dr3`
- Phase G closure notes and non-remote release-readiness checklist status
- per-phase build and quality gates
- edge-case audit closure summary

Those have now been split as follows:

- current review and robustness procedure:
  `docs/plans/implemented-nip-review-guide.md`
- current requested-NIP execution packet:
  `docs/plans/post-kernel-requested-nips-loop.md`
- current active baseline:
  `docs/plans/build-plan.md`
- historical phase evidence:
  `docs/archive/plans/phase-f-*.md`
  and other archive plan docs in this directory

## Archived Risks, Tradeoffs, And Questions

The pre-trim build plan carried:

- `R-E-*` and `A-E-*` risk / assumption registers
- `UT-E-*` unresolved tradeoff register entries
- `OQ-E-*` open questions
- the Phase E ambiguity checkpoint
- Phase E implementation-handoff definition of done
- tradeoffs `T-E-001` through `T-E-003`
- principles-compliance notes

Most of those were historical phase-planning material rather than current startup guidance.

The only still-live item from that set that remains active is:

- `OQ-E-006`
  - complete the LLM-first usability evaluation closure criteria in
    `docs/plans/llm-usability-pass.md` before release-candidate API freeze

## Active Replacements

Use these instead of treating this archive as current guidance:

- `docs/plans/build-plan.md`
  - lean active execution baseline
- `docs/plans/implemented-nip-review-guide.md`
  - current implemented-surface review and robustness procedure
- `docs/plans/decision-index.md`
  - startup route into policy decisions
- `docs/plans/post-kernel-requested-nips-loop.md`
  - current requested-NIP loop order and rules
- `handoff.md`
  - current next work and current repo state
