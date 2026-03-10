# Starter Framework

Copy this framework into a new repo, then tune only the project profile before phase work starts.

## Decisions

- `SF-001`: the starter framework contains only universal process artifacts and minimal placeholders.
- `SF-002`: project-specific configuration lives in one profile file instead of being scattered across
  prompts.
- `SF-003`: the starter remains phase-driven, but phase names and counts are configurable.

## Framework Layers

1. Universal process rules
   - `AGENTS.md`
   - `docs/process/process-principles.md`
   - `docs/process/agent-prompt-template.md`
   - `docs/process/phase-prompt-template.md`
2. Project profile rules
   - `docs/process/project-profile.md`
3. Active project execution artifacts
   - `docs/plans/decision-log.md`
   - `docs/plans/build-plan.md`
   - `docs/plans/prompts/`
   - `handoff.md`

## Minimal File Tree

```text
template/
├── AGENTS.md
├── handoff.md
└── docs/
    ├── process/
    │   ├── agent-prompt-template.md
    │   ├── phase-prompt-template.md
    │   ├── process-principles.md
    │   └── project-profile.md
    └── plans/
        ├── build-plan.md
        ├── decision-log.md
        └── prompts/
            ├── README.md
            └── phase-0-bootstrap.md
```

## Purpose Of Each File

- `AGENTS.md`: startup order, authority rules, quality gates, clarification protocol, session-end
  workflow.
- `handoff.md`: current state, next action, open questions, deferred work.
- `docs/process/agent-prompt-template.md`: reusable repo-audit and new-project kickoff prompts.
- `docs/process/phase-prompt-template.md`: one-phase prompt scaffold with ambiguity and exit gates.
- `docs/process/process-principles.md`: reusable process defaults and anti-goals.
- `docs/process/project-profile.md`: project-specific purpose, references, constraints, commands,
  phases, and policy overrides.
- `docs/plans/decision-log.md`: immutable decision and closure evidence register.
- `docs/plans/build-plan.md`: active executable plan with phase gates.
- `docs/plans/prompts/README.md`: prompt order and common prompt rules.
- `docs/plans/prompts/phase-0-bootstrap.md`: first phase prompt to build planning context.

## Canonical Initialization Order

1. `AGENTS.md`
2. `docs/process/process-principles.md`
3. `docs/process/project-profile.md`
4. `docs/plans/decision-log.md`
5. `docs/plans/build-plan.md`
6. `docs/plans/prompts/README.md`
7. active phase prompt
8. `handoff.md`

## What Is Mandatory

- declared artifact authority
- project profile completed before implementation
- one prompt per active phase
- decision log with controlled default changes
- ambiguity checkpoint before phase closure
- written handoff
- explicit verification commands
- explicit local versus remote completion policy

## What Is Configurable

- phase names and count
- language and style guide
- dependency and security policy
- build, test, lint, release commands
- issue tracker and workflow tooling
- remote-readiness rules
- domain references and research inputs

## Minimum Adoption Steps

1. Copy `template/` into the new repo.
2. Fill out `docs/process/project-profile.md`.
3. Adjust `AGENTS.md` startup order if the project has extra canonical docs.
4. Review and adapt `docs/process/agent-prompt-template.md` and
   `docs/process/phase-prompt-template.md` for the new project's profile.
5. Define the first phase prompt in `docs/plans/prompts/`.
6. Run the kickoff prompt from `docs/process/agent-prompt-template.md`.

## Tradeoffs

## Tradeoff T-SF-001: Minimal tree versus richer starter repo

- Context: a smaller tree is easier to adopt, but a richer tree can reduce setup choices.
- Options:
  - O1: minimal tree with clear responsibilities.
  - O2: broader tree with built-in release, review, and tracker files.
- Decision: O1.
- Benefits: lower copy cost and less accidental boilerplate sprawl.
- Costs: some follow-on files still need project-specific creation.
- Risks: teams may forget optional but useful artifacts.
- Mitigations: document add-on candidates in the project profile.
- Reversal Trigger: repeated adoption friction caused by missing common files.
- Principles Impacted: `P01`, `P03`, `P08`.
- Scope Impacted: `template/`, onboarding steps, kickoff setup.

## Open Questions

- `OQ-SF-001`: should the starter add an optional `docs/release/` skeleton by default?

## Principles Compliance

- `P01`: file roles and initialization order are explicit.
- `P03`: phase prompts remain separate from the project profile.
- `P04`: default changes route through the decision log.
- `P06`: phase closure requires ambiguity handling.
- `P07`: handoff is mandatory.
- `P08`: only universal files are mandatory in the starter.
