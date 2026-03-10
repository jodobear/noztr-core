# Process Principles

## Frozen Defaults

- `D-001` Declare canonical artifact authority.
- `D-002` One prompt per phase.
- `D-003` Log default changes and material decisions.
- `D-004` Stop on unresolved high-impact ambiguity.

## Principles

- `P01`: canonical artifacts outrank conversational context.
- `P02`: clarifying questions come before risky guesses.
- `P03`: prompts must be operational and phase-local.
- `P04`: defaults change only through explicit decisions.
- `P05`: material tradeoffs must be recorded.
- `P06`: phase closure requires ambiguity review.
- `P07`: project state must be written to handoff artifacts.
- `P08`: keep this framework small; put specialization in the project profile.

## Clarifying Question Gate

1. Check canonical artifacts first.
2. Check whether the ambiguity is already resolved in the project profile, decision log, build plan,
   or active phase prompt.
3. If the ambiguity is high impact, stop and ask one targeted clarifying question before proceeding.

Use this format:

```md
### Clarifying Question CQ-<phase>-<number>

- Topic: <what is unclear>
- Why It Matters: <what decision depends on it>
- Options:
  - O1: <option>
  - O2: <option>
- Recommended Default: <default choice>
- Stop Condition: do not advance past <phase/task> until resolved
- Owner: <user / operator / phase owner>
```

## Anti-Goals

- Do not rely on chat memory instead of canonical repo artifacts.
- Do not silently change defaults.
- Do not advance past high-impact ambiguity because a default seems likely.

## Tradeoffs

- Record one tradeoff entry for every material decision.

## Open Questions

- Replace with project-specific open questions during bootstrap.

## Principles Compliance

- Artifact authority is explicit.
- Clarifying-question behavior is explicit.
- Tradeoffs and open questions are recorded.
