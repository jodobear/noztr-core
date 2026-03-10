# Project Profile Template

Copy this into `docs/process/project-profile.md` for a new repo and fill in every field before
implementation starts.

## Project Identity

- Project Name:
- Purpose:
- Success Criteria:
- In Scope:
- Out Of Scope:

## Canonical References

- Primary references:
- Secondary references:
- Reference precedence:
- External resources/assets:

## Technical Profile

- Language/toolchain:
- Runtime targets:
- Dependency policy:
- Allowed exception process:
- Architecture constraints:
- Safety/security/performance constraints:

## Verification Profile

- Build commands:
- Test commands:
- Lint/format commands:
- Required quality gates after code changes:
- Definition of done:

## Process Profile

- Delivery phases:
- Phase order:
- Issue tracking method:
- Branch/merge policy:
- Remote/push policy:
- Session-end landing workflow:

## Clarification Gate

Before starting planning or coding, verify these are clear enough:

- purpose
- success criteria
- scope boundaries
- canonical references
- language/toolchain
- dependency policy
- quality gates
- issue tracking
- remote/push expectations
- major constraints

If any missing item materially changes setup, architecture, or risk posture, ask a clarifying
question before proceeding.

## Initial Open Questions

- `OQ-START-001`:
- `OQ-START-002`:

## Decisions

- `PP-001`: fill project-local defaults here instead of scattering them across prompts.

## Tradeoffs

## Tradeoff T-PP-001: Strict project profile completion versus rapid kickoff

- Context: detailed profiles slow the start but reduce drift.
- Options:
  - O1: require a filled project profile before implementation.
  - O2: allow partial profiles and patch details later.
- Decision: O1 by default.
- Benefits: clearer authority, fewer silent assumptions.
- Costs: more setup effort before coding.
- Risks: teams may keep profiles stale after kickoff.
- Mitigations: require profile updates when accepted defaults change.
- Reversal Trigger: repeated small-project evidence that full profiles add cost without reducing
  ambiguity.
- Principles Impacted: `P01`, `P02`, `P04`, `P07`.
- Scope Impacted: kickoff workflow, ongoing project maintenance.

## Open Questions

- Replace placeholders above before phase closure.

## Principles Compliance

- `P01`: project-local authority and defaults are centralized.
- `P02`: the pre-start clarification gate is explicit.
- `P04`: overrides are expected to be documented, not implicit.
- `P07`: profile updates are part of ongoing state continuity.
