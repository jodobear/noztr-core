---
title: Packet Template
doc_type: reference
status: active
owner: noztr
read_when:
  - creating_a_new_packet
  - repairing_packet_drift
depends_on:
  - docs/guides/PROCESS_CONTROL.md
  - docs/guides/IMPLEMENTATION_QUALITY_GATE.md
canonical: true
---

# Packet Template

Use this template for a new active packet. Keep packets delta-oriented. They should not restate the
full repo process or duplicate handoff/build-plan responsibilities.

## Frontmatter Skeleton

```yaml
---
title: <Packet Title>
doc_type: packet
status: active
owner: noztr
phase: <phase-name>
read_when:
  - <when_this_packet_is_needed>
depends_on:
  - docs/plans/build-plan.md
  - docs/guides/IMPLEMENTATION_QUALITY_GATE.md
target_findings:
  - <optional-finding-id>
sync_touchpoints:
  - handoff.md
  - docs/README.md
canonical: true
---
```

## Required Sections

### Purpose

- what active slice this packet exists for
- what it does not cover

### Scope Delta

- slice-specific scope only
- seam constraints that differ from the generic implementation gate
- explicit out-of-scope items

### Current Status

- what is complete
- what remains active right now
- which older packets are now reference-only, if relevant

### Next Step

- the immediate next slice or decision
- any gating dependency that must be cleared first

### Open Questions Or Targeted Findings

- only active questions or finding IDs that still shape the slice
- do not preserve resolved history here

### Sync Touchpoints

- teaching surface
- audit state
- startup and discovery docs

### Closeout Conditions

- what must be true before this packet can become `reference` or move to archive

## Packet Rules

- link to `docs/guides/IMPLEMENTATION_QUALITY_GATE.md` instead of copying the full loop
- point to canonical owners instead of re-explaining their doctrine
- when the lane closes but the phase remains active, create or update the next current packet
- when the packet is no longer current, change `status` and remove it from active routing
