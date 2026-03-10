# Research And Guides Catalog

Status: process-evaluation artifact only. This document classifies current `noztr` research and
guides by portability so shared-corpus extraction can happen without changing canonical product
artifacts.

## Research Classification

| Document | Category | Portability | Recommended destination |
| --- | --- | --- | --- |
| `docs/research/building-nostr-study.md` | Domain philosophy | High | shared corpus `protocols/nostr/philosophy/` |
| `docs/research/nostr-protocol-study.md` | Protocol survey | Medium | shared corpus `protocols/nostr/`, then split by NIP |
| `docs/research/v1-protocol-reference.md` | Scope-bound protocol reference | Medium | split shared protocol facts from noztr-specific strictness notes |
| `docs/research/applesauce-study.md` | Library study | Medium | shared corpus `libraries/applesauce/` |
| `docs/research/rust-nostr-study.md` | Library study | Medium | shared corpus `libraries/rust-nostr/` |
| `docs/research/libnostr-z-study.md` | Library study | Medium | shared corpus `libraries/libnostr-z/` |
| `docs/research/v1-applesauce-deep-study.md` | Project-scoped parity study | Low | keep project-local; extract transferable patterns only |
| `docs/research/v1-rust-nostr-deep-study.md` | Project-scoped parity study | Low | keep project-local; extract transferable patterns only |
| `docs/research/v1-libnostr-z-deep-study.md` | Project-scoped parity study | Low | keep project-local; extract transferable patterns only |
| `docs/research/v1-zig-implementation-notes.md` | Language-to-project translation | Medium | split Zig-general notes into shared `languages/zig/` |
| `docs/research/v1-implementation-decisions.md` | Project decision synthesis | Low | keep project-local |
| `docs/research/zig-ecosystem-crypto-survey.md` | Zig ecosystem survey | Medium | shared corpus `languages/zig/crypto/` with noztr overlay note |

## Guide Classification

| Document | Category | Portability | Recommended destination |
| --- | --- | --- | --- |
| `docs/guides/TIGER_STYLE.md` | Imported general style reference | High | shared corpus `guides/style/third-party/` |
| `docs/guides/docs-style_guide.md` | General docs guide | High | shared corpus `guides/documentation/` |
| `docs/guides/NOZTR_STYLE.md` | Nostr+Zig style profile | Medium | shared corpus `packs/nostr-zig/guides/` |
| `docs/guides/zig-patterns.md` | `noztr` v1-safe patterns | Medium | split Zig-general patterns from Nostr-module specifics |
| `docs/guides/zig-anti-patterns.md` | `noztr` v1 anti-patterns | Medium | split Zig-general anti-patterns from module-specific triggers |
| `docs/guides/performance.md` | Imported engineering guide | High | shared corpus `guides/performance/third-party/` |
| `docs/guides/upgrades.md` | Project-foreign operational guide | Low | do not import as shared default for software starters |
| `docs/guides/building-nostr.pdf` | Source reference | Medium | shared corpus source archive with extracted notes only |
| `docs/guides/io_uring.pdf` | Source reference | Low | only include if a future project depends on it directly |

## Suggested Extraction Rules

- Export whole documents only when portability is high and local coupling is low.
- Split documents when transferable sections are mixed with noztr-specific decisions.
- Keep deep parity studies, build decisions, and phase records project-local.
- Convert strong combinations into packs.
  - Example: `NOZTR_STYLE` + Zig safety patterns + Nostr protocol philosophy => `nostr-zig` pack.

## First Shared Packs To Build

1. `process-core`
   - process principles
   - starter framework
   - prompt templates
2. `nostr-general`
   - Building Nostr philosophy
   - Nostr protocol survey
   - cleaned NIP reference notes
3. `zig-core`
   - Zig implementation notes that are not Nostr-bound
   - general anti-patterns and patterns
4. `nostr-zig`
   - Nostr philosophy
   - Zig core
   - NOZTR-style-derived profile stripped of repo-local policy

## Extraction Method

1. Add metadata to candidate shared docs.
2. Mark paragraphs as `shared`, `pack-only`, or `project-local`.
3. Extract high-portability content first.
4. Keep a source-to-export mapping table so provenance remains explicit.
5. Pin snapshots into consuming repos when stability matters.
