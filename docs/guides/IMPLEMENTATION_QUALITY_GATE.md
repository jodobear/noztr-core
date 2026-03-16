---
title: Implementation Quality Gate
doc_type: policy
status: active
owner: noztr
read_when:
  - starting_new_implementation_slice
  - starting_new_audit_slice
  - reviewing_candidate_closeout
depends_on:
  - AGENTS.md
  - docs/guides/PROCESS_CONTROL.md
  - docs/plans/decision-index.md
canonical: true
---

# Implementation Quality Gate

Canonical staged execution order for `noztr` implementation, audit, and robustness slices.

Use this gate for any new code-bearing or behavior-changing slice unless a more specific packet adds
only slice-specific deltas. Do not restate this whole loop inside a packet.

Specialized references:
- `docs/plans/implemented-nip-review-guide.md`
  - implemented-NIP audit and robustness-specific review posture
- `docs/plans/packet-template.md`
  - shared packet skeleton for new active slices

## Gate Order

1. Tracker and freeze
   - claim the `br` issue
   - freeze the exact slice and non-goals
   - record the micro-freeze:
     - scope and non-goals
     - accepted valid input versus canonical emitted output
     - invalid-vs-capacity matrix
     - reject corpus where needed
     - sync touchpoints
   - stop if the slice requires a frozen-default change

2. Implement the accepted slice
   - keep the surface bounded, deterministic, and inside protocol-kernel ownership
   - add tests and examples with the code instead of later
   - do not widen scope to absorb adjacent workflow or SDK behavior

3. Review A
   - validate correctness, trust-boundary behavior, and parity/evidence posture
   - minimum prompts for parser/builder trust boundaries:
     - can invalid input still panic or hit a debug assertion
     - can invalid input still leak as a capacity error
     - can capacity failure still leak as an invalid-input error
     - does any scan escape the intended syntactic region
     - does the parser accept nonsense because delimiters balance

4. Fix Review A findings

5. Review B
   - validate kernel-vs-SDK ownership, usability, overengineering, and final public teaching shape
   - minimum prompts:
     - did canonicalization become over-strict input validation
     - did the surface stay inside deterministic kernel ownership
     - did workflow or policy behavior leak in from the SDK layer
     - do examples show intended use and intended rejection

6. Fix Review B findings

7. Adversarial audit
   - force public error variants directly
   - run builder/parser symmetry where both surfaces exist
   - run hostile and contradictory inputs where the surface warrants them
   - for tokenized or sectioned grammars, challenge nonsense tokens and separator discipline
   - when reference evidence is weak or `LIB_UNSUPPORTED`, rerun the spec-first challenge pass

8. Green gates
   - run focused checks first when useful
   - if code changed, final closure requires fresh:
     - `zig build test --summary all`
     - `zig build`
   - docs-only passes do not need Zig gates, but they still need routing and coherence review

9. Closeout synchronization
   - apply the declared sync touchpoints explicitly:
     - teaching surface
     - audit state
     - startup and discovery docs
   - update canonical docs only where policy, accepted behavior, or current state changed
   - if no canonical doc changed, record that explicitly in tracker evidence

10. Scoped landing
   - make one scoped git commit for the completed slice
   - close or update the `br` issue
   - if tracker state changed:
     - `br ...`
     - `br sync --flush-only`
     - `git add .beads/`
     - `git commit -m "sync beads"`

## Required Outputs

- one explicit freeze note
- one Review A result
- one Review B result
- one adversarial audit result
- fresh final gate result when code changed
- explicit docs/examples closeout
- one scoped commit

## Stop Conditions

- a frozen default or policy change is required
- the slice would require unbounded allocation or workflow-coupled behavior
- parity or spec evidence exposes a material semantic conflict that is not already accepted
- the code passes only by weakening typed errors or trust-boundary checks

## Routing Rule

- packets should add only slice-specific deltas on top of this gate
- `handoff.md` should point to the current active packet or next work, not restate this loop
- `docs/plans/implemented-nip-review-guide.md` stays specialized; it does not replace this repo-wide
  gate
