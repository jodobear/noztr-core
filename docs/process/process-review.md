# Process Review

Review target: extract the reusable parts of noztr's process without copying protocol-specific or
language-specific policy into future projects by accident.

## Decisions

- `PR-001`: keep the reusable framework small and layered.
  - Universal layer: authority, gates, decision discipline, clarification protocol, handoff.
  - Profile layer: language, toolchain, dependency policy, build commands, delivery phases.
  - Project-local layer: domain rules, parity sources, active roadmap, release posture.
- `PR-002`: preserve the current repo's strong stop conditions.
  - High-impact ambiguity blocks phase closure.
  - Material decisions require tradeoff records.
  - Session state must be written to canonical artifacts, not left in chat history.
- `PR-003`: keep prompts operational.
  - Every prompt must name exact inputs, outputs, verification commands, and stop conditions.

## What Works Well

- Canonical startup order exists and reduces cold-start drift.
- Artifact authority is explicit; not every document has equal weight.
- One-prompt-per-phase keeps planning outputs narrow and auditable.
- Frozen defaults plus decision-log entries prevent silent policy drift.
- Tradeoff records force rationale, risks, and reversal triggers into the open.
- Ambiguity checkpoints prevent momentum from hiding unresolved architectural risk.
- Handoff discipline preserves session continuity without relying on memory.
- Completion workflow distinguishes local closure from remote landing.

## Keep As Universal Boilerplate

- Canonical artifact precedence.
- Frozen defaults plus controlled change log.
- One active phase at a time.
- One prompt per phase.
- Material decisions require tradeoff records.
- Clarifying-question gate before risky work.
- High-impact ambiguity blocks advancement.
- Quality gates after code changes.
- Written handoff and landing-the-plane workflow.

## Move To Project-Profile Layer

- Language and style rules.
- Dependency policy and approved exceptions process.
- Build, test, lint, and release commands.
- Issue tracker choice and command examples.
- Remote and push policy.
- Phase names, delivery lanes, and scope model.
- Security, performance, or compliance posture.

## Keep Project-Local Only

- Nostr principles, NIP sequencing, and parity-source snapshots.
- Zig-specific coding constraints from TigerStyle and NOZTR style.
- Active Phase H roadmap and current interop cadence.
- Current rust-only parity governance and archive-only TypeScript lane.

## Remove As Unnecessary Overhead For New Repos

- Hard-coded phase letters tied to this repo's research history.
- Protocol-specific artifact names in generic startup instructions.
- Repo-specific tracker IDs and remote-readiness exceptions.

## Risks If Copied Blindly

- Copying Zig or Nostr rules into an unrelated repo would turn profile choices into false
  universals.
- Copying the full phase catalog into a small project would create ceremony without reducing risk.
- Copying tracker tooling as mandatory would overfit to one team workflow.
- Copying remote-landing rules without declaring scope could create false completion claims.

## Tradeoffs

## Tradeoff T-PR-001: Small starter kit versus exhaustive policy bundle

- Context: a starter framework must be useful on day one without becoming another heavyweight
  internal platform.
- Options:
  - O1: small framework with strict core rules and configurable project profile.
  - O2: large framework that pre-bakes language, release, and tracker conventions.
- Decision: O1.
- Benefits: easier adoption, less accidental overfitting, lower maintenance cost.
- Costs: more profile setup work for each new repo.
- Risks: teams may under-specify profiles and leave important defaults implicit.
- Mitigations: require a project profile and pre-start clarification gate.
- Reversal Trigger: repeated new-project failures trace back to missing starter defaults.
- Principles Impacted: `P01`, `P02`, `P04`, `P05`, `P08`.
- Scope Impacted: reusable boilerplate, template tree, kickoff prompts.

## Tradeoff T-PR-002: Strong stop conditions versus faster early motion

- Context: forcing explicit ambiguity handling slows the first pass but reduces rework.
- Options:
  - O1: stop on high-impact uncertainty and ask a clarifying question.
  - O2: allow agents to choose likely defaults and clean up later.
- Decision: O1.
- Benefits: lower architectural drift and fewer expensive reversals.
- Costs: more front-loaded questioning in unclear projects.
- Risks: teams may perceive the process as slow if profiles are incomplete.
- Mitigations: keep clarification targeted and require a recommended default in every question.
- Reversal Trigger: evidence that the clarification gate blocks low-risk work more than it helps.
- Principles Impacted: `P02`, `P05`, `P06`.
- Scope Impacted: kickoff flow, phase closure rules, agent prompts.

## Open Questions

- `OQ-PR-001`: should the starter ship with one default tracker integration or remain tracker-agnostic
  at the framework layer?
- `OQ-PR-002`: should the starter include a default release-readiness checklist file or leave that to
  the project profile?

## Principles Compliance

- `P01`: separates canonical framework artifacts from project-local planning documents.
- `P02`: preserves clarifying-question gates before costly work starts.
- `P03`: keeps prompts phase-local and operational.
- `P04`: requires explicit change control for defaults.
- `P05`: keeps ambiguity and tradeoff handling mandatory.
- `P06`: preserves measurable gates and stop conditions.
- `P07`: retains state continuity and landing workflow.
- `P08`: keeps the reusable framework profile-driven rather than domain-bound.
