# Process Principles

Reusable process baseline for starting new software projects with an agent.

## Frozen Defaults

These defaults are meant to be copied into new repos unless the project profile overrides them
explicitly.

- `D-001` Artifact authority must be declared at repo start.
- `D-002` Work advances one phase at a time with one prompt per phase.
- `D-003` Material decisions require tradeoff records and controlled change logging.
- `D-004` High-impact ambiguity blocks phase closure and may require a clarifying question.

## Decisions

- `P01` Rule: declare canonical artifacts and their precedence before planning or coding.
  - Rationale: agents need a stable source of truth to avoid policy drift.
- `P02` Rule: ask clarifying questions before crossing costly, risky, or irreversible boundaries.
  - Rationale: targeted questions are cheaper than architectural rework.
- `P03` Rule: keep prompts phase-local and operational.
  - Rationale: exact inputs, outputs, and stop conditions produce better work than broad briefs.
- `P04` Rule: freeze defaults explicitly and change them only through a decision log.
  - Rationale: default changes are policy changes and must be auditable.
- `P05` Rule: record tradeoffs for every material decision.
  - Rationale: a decision without context cannot be reviewed or reversed well.
- `P06` Rule: do not close a phase while high-impact ambiguity remains `decision-needed`.
  - Rationale: unresolved risk compounds downstream.
- `P07` Rule: write state continuity artifacts after meaningful progress and at session end.
  - Rationale: a repo should remain operable across agents and sessions.
- `P08` Rule: keep the framework small and push specialization into a project profile.
  - Rationale: reusable process should travel; domain constraints should not.

## Clarifying Question Gate

Use this escalation order:

1. Check canonical artifacts first.
2. Check whether the ambiguity is already resolved in principles, decision log, build plan, project
   profile, or active phase prompt.
3. Classify the ambiguity.
   - Low impact: choose the documented default and record it.
   - Medium impact: proceed only if the default does not change architecture, scope, safety, or
     delivery commitments.
   - High impact: stop and ask one targeted clarifying question.

Ask clarifying questions especially before:

- starting the first planning phase
- starting implementation
- changing defaults
- introducing dependencies
- changing architecture
- resolving conflicting references
- making irreversible or high-cost choices

Use this format:

```md
### Clarifying Question CQ-<phase>-<number>

- Topic: <what is unclear>
- Why It Matters: <what decision depends on it>
- Options:
  - O1: <option>
  - O2: <option>
  - O3: <option, if needed>
- Recommended Default: <default choice>
- Stop Condition: do not advance past <phase/task> until resolved
- Owner: <user / operator / phase owner>
```

## Anti-Goals And Forbidden Shortcuts

- Anti-goal: rely on chat memory instead of canonical repo artifacts.
- Anti-goal: let implementation outrun scope, constraints, or authority decisions.
- Anti-goal: use broad prompts that hide missing inputs or mixed phases.
- Forbidden shortcut: silently changing defaults without a decision-log entry.
- Forbidden shortcut: advancing past a high-impact ambiguity because a default feels likely.
- Forbidden shortcut: marking work complete without running declared gates.
- Forbidden shortcut: treating project-specific language or domain rules as universal process law.

## Tradeoffs

## Tradeoff T-P-001: Explicit process artifacts versus lightweight improvisation

- Context: some teams prefer less documentation, but agents need structured authority and state.
- Options:
  - O1: explicit canonical artifacts and update duties.
  - O2: minimal docs and conversational coordination.
- Decision: O1.
- Benefits: stronger repeatability, easier reviews, lower context loss.
- Costs: some documentation overhead.
- Risks: cargo-cult artifact creation without substance.
- Mitigations: keep the framework small and require operational content only.
- Reversal Trigger: evidence that the artifacts do not improve handoff quality or decision traceability.
- Principles Impacted: `P01`, `P04`, `P07`, `P08`.
- Scope Impacted: starter framework, project profile, handoff.

## Tradeoff T-P-002: Clarification gate versus default-forward execution

- Context: autonomous agents are faster when they guess, but incorrect guesses are costly.
- Options:
  - O1: targeted clarification on high-impact ambiguity.
  - O2: default-forward execution unless explicitly blocked.
- Decision: O1.
- Benefits: lower rework and clearer authority handling.
- Costs: more up-front pauses when profiles are incomplete.
- Risks: users may under-value profile setup and experience avoidable questions.
- Mitigations: require recommended defaults and one-question-at-a-time discipline.
- Reversal Trigger: repeated evidence that the gate blocks low-risk progress without preventing rework.
- Principles Impacted: `P02`, `P05`, `P06`.
- Scope Impacted: kickoff prompt, phase prompts, phase closure.

## Open Questions

- `OQ-P-001`: whether the starter should include a mandatory review template for non-code work.
- `OQ-P-002`: whether a default risk register belongs in the universal starter or the project
  profile layer.

## Principles Compliance

- Required framework behavior maps to `P01` through `P08`.
- Clarifying-question format is explicit and reusable.
- Frozen defaults are declared and change-controlled.
- Anti-goals and forbidden shortcuts are explicit.
- Tradeoffs and open questions are mandatory.
