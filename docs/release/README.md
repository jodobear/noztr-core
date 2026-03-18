---
title: Release Docs Index
doc_type: release_index
status: active
owner: noztr
read_when:
  - evaluating_noztr_publicly
  - onboarding_external_consumers
  - routing_public_release_docs
canonical: true
---

# Release Docs Index

This is the public-facing documentation route for `noztr`.

Use these docs if you are evaluating the library, comparing it to other Nostr libraries, or trying
to understand the current release-facing contract at a high level.

## Start Here

- `README.md`
  - short overview, status, build/test commands, and quick-start routing
- `docs/release/noztr-positioning.md`
  - what `noztr` is trying to do, why it exists, tradeoffs, limitations, and comparisons
- `docs/release/intentional-divergences.md`
  - release-facing behavior differences that are intentional in Layer 1

## Public Technical Entry Points

- `examples/README.md`
  - task-oriented example routing
- `docs/plans/v1-api-contracts.md`
  - older core contract reference for events, filters, and messages
- `docs/plans/post-core-contract-map.md`
  - task-to-symbol route for the main post-core public surfaces

## Important Note On Internal Docs

This repo also contains extensive internal working documents under `docs/plans/` and
`docs/research/`.

Those documents are valuable for provenance and engineering rigor, but they are not the primary
public documentation surface.

In general:

- `docs/release/` is public-facing release documentation
- `examples/` is public-facing usage material
- `docs/plans/` is mostly internal planning, execution, and contract-routing material
- `docs/research/` is mostly internal audit, study, and evidence material

If you are not actively contributing to `noztr`, start with the release docs and examples first.
