# Phase Prompt Template

Use one prompt per phase. Do not combine phases in one run.

## Template

```md
# Phase <id>: <name>

Goal: <single clear outcome for this phase>

## Inputs

- <canonical input 1>
- <canonical input 2>
- <canonical input 3>

## Required Work

- <task 1>
- <task 2>
- <task 3>

## Required Output

- `<file/path>`
  - <required content>
- `<file/path>`
  - <required content>

## Clarifying Question Gate

Before closing the phase, verify whether any ambiguity materially changes:
- scope
- architecture
- dependencies
- trust boundaries
- delivery schedule
- quality gates

If yes:
- classify the ambiguity as `resolved`, `accepted-risk`, or `decision-needed`
- ask one targeted clarifying question if impact is high
- stop phase advancement until resolved

Use this format:

### Clarifying Question CQ-<phase>-<number>
- Topic: <unclear point>
- Why It Matters: <decision affected>
- Options:
  - O1: <option>
  - O2: <option>
- Recommended Default: <recommended path>
- Stop Condition: do not advance past this phase until resolved
- Owner: <user/operator/phase owner>

## Exit Criteria

- <measurable gate 1>
- <measurable gate 2>
- <measurable gate 3>

## Stop Conditions

Stop and record an open question instead of guessing if:
- canonical inputs conflict
- a default may be unsafe to generalize
- the phase would require cross-phase output
- the ambiguity is high impact
```

## Prompt Rules

- Name exact inputs.
- Name exact outputs and file targets.
- Keep outputs phase-local.
- Record material decisions as tradeoffs.
- Include measurable gates.
- Include stop conditions.
- Do not hide implementation work inside planning phases.

## Minimal Review Checklist

- Are the inputs canonical and sufficient?
- Are outputs concrete and file-bound?
- Are tradeoff and ambiguity duties explicit?
- Could another agent execute the phase without extra discovery?
