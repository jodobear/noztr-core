# Agent Prompt Template

Use this as the two-part prompt package for future projects.

## Part 1: Extract Boilerplate From A Mature Repo

```md
You are reviewing an existing software project to extract its reusable operating system.

Goal: turn this repo's working process into a small, copyable boilerplate for future projects.

Your job is to:
- review the current process
- identify what is universal vs project-specific
- extract reusable principles
- create a starter framework
- create prompt templates for future agents

## Required Review Areas

Examine:
- startup instructions
- artifact precedence and authority
- frozen defaults and decision logging
- phase structure and phase prompts
- ambiguity checkpoints and stop conditions
- clarifying-question rules
- quality gates after code changes
- issue tracking workflow
- handoff and session continuity
- local and remote landing workflow

## Classification Rule

For each major process element, classify it as:
- Keep as universal boilerplate
- Move to project-profile layer
- Keep project-local only
- Remove as unnecessary overhead

Justify each classification.

## Clarifying Question Protocol

Do not guess through important ambiguity.
Before proceeding:
1. check canonical artifacts
2. check whether the ambiguity is already resolved
3. classify impact: low, medium, high
4. if high impact, stop and ask one targeted clarifying question

Ask clarifying questions especially before:
- starting the first planning phase
- starting implementation
- changing defaults
- introducing dependencies
- changing architecture
- resolving conflicting references
- making costly or irreversible choices

Use this format:

### Clarifying Question CQ-<area>-<number>
- Topic: <unclear point>
- Why It Matters: <decision affected>
- Options: <short options>
- Recommended Default: <recommended path>
- Stop Condition: do not advance past <phase/task> until resolved
- Owner: <user/operator>

## Deliverables

Produce:
- `docs/process/process-review.md`
- `docs/process/process-principles.md`
- `docs/process/starter-framework.md`
- `docs/process/project-profile-template.md`
- `docs/process/agent-prompt-template.md`
- `docs/process/phase-prompt-template.md`
- `template/` starter directory with minimal placeholder files

## Mandatory Features To Preserve

The reusable framework must preserve:
- canonical artifact precedence
- frozen defaults plus controlled change log
- one-prompt-per-phase discipline
- measurable exit criteria
- tradeoff records for material decisions
- ambiguity checkpoint before phase closure
- clarifying-question gate before risky work
- stop on unresolved high-impact uncertainty
- quality gates after code changes
- handoff/state continuity
- explicit local/remote completion workflow

## Output Rules

Make everything:
- concrete
- copyable
- small
- operational
- explicit about what is mandatory
- explicit about what is configurable

For principle and decision-style docs include:
- `Decisions`
- `Tradeoffs`
- `Open Questions`
- `Principles Compliance`

Stop and record an open question instead of guessing if a rule may be domain-specific,
language-specific, or unsafe to generalize.
```

## Part 2: New Project Kickoff Prompt

```md
You are starting a new project using this repo's process boilerplate.

Your first job is not broad implementation. Your first job is to initialize the project correctly,
resolve critical ambiguity, and create the phase-ready working context.

## Inputs

Use these artifacts first:
- `AGENTS.md`
- `docs/process/process-principles.md`
- `docs/process/starter-framework.md`
- `docs/process/project-profile.md`
- `docs/process/agent-prompt-template.md`
- `docs/process/phase-prompt-template.md`

Also consume the project-specific profile for this repo:
- purpose
- success criteria
- scope and non-scope
- references and authority
- language/toolchain
- dependency policy
- build/test commands
- constraints
- resources
- delivery phases
- issue tracking policy
- remote/push policy

## Pre-Start Clarification Gate

Before creating plans or code, verify that these are clear enough:
- project purpose
- success criteria
- scope boundaries
- canonical references
- language/toolchain
- dependency policy
- quality gates
- issue tracking method
- remote/push expectations
- major safety/security/performance constraints

If any missing item would materially change setup or architecture, stop and ask a clarifying
question.

Use this format:

### Clarifying Question CQ-START-<number>
- Topic: <unclear point>
- Why It Matters: <decision affected>
- Options: <short options>
- Recommended Default: <recommended path>
- Stop Condition: do not start <phase/task> until resolved
- Owner: <user/operator>

## Execution Rules

- read canonical artifacts in order
- respect artifact precedence
- work one phase at a time
- do not combine phases
- record tradeoffs for material decisions
- run ambiguity checkpoint before phase closure
- stop advancement on unresolved high-impact ambiguity
- update project state after meaningful progress
- run quality gates after code changes
- complete handoff and landing workflow at session end

## Required Outputs

Create or update:
- the project profile
- the canonical planning docs for the current phase
- the decision log
- the handoff/state artifact
- the phase prompt for the active phase if missing

## Prompt Quality Rule

All work must specify:
- exact inputs
- exact outputs
- exact files to create/update
- exact verification commands
- exact stop conditions
- exact artifact update responsibilities

Avoid:
- vague multi-phase exploration
- silent default changes
- hidden architecture choices
- implementation before scope/process clarity
- guessing through high-impact ambiguity
```
