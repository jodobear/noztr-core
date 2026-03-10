# Shared Knowledge Strategy

Status: process-evaluation artifact only. This document is not a canonical noztr product-planning
input and should not change current Phase H execution.

## Decision

Build the broader shared research and guide system in a separate project, not inside `noztr`.

## Why Separate

- `noztr` already has active phase execution and canonical startup artifacts.
- Cross-project corpus work has different goals: curation, normalization, tagging, and export.
- Mixing those concerns into this repo increases the chance another agent reads non-noztr policy as
  active product guidance.
- A separate project can version shared knowledge independently and serve many repos.

## Recommended Model

Use a two-tier system:

1. Shared corpus repo
   - durable cross-project research, guides, and prompt packs
   - language, protocol, library, and process knowledge
   - explicit metadata for scope, status, portability, and review date
2. Project overlay repo
   - project-local decisions, build plan, handoff, and specialized guides
   - imports or references the shared corpus instead of copying everything

## Corpus Categories

- `process/`: reusable operating-system docs, prompt templates, decision patterns
- `languages/`: Zig, Rust, TypeScript, etc.
- `protocols/`: Nostr core, individual NIPs, wire-format notes
- `libraries/`: applesauce, rust-nostr, libnostr-z, backend wrappers
- `guides/`: style profiles, documentation guides, review checklists
- `packs/`: composable bundles such as `nostr+zig`, `nostr+ts`, `relay-server`

## Recommended File Metadata

Every shared document should declare:

- Title
- Category
- Scope: `shared`, `pack`, or `project-local`
- Portability: `high`, `medium`, or `low`
- Audience
- Source provenance
- Last reviewed date
- When to use
- When not to use
- Dependent packs or guides

## Suggested Repo Shape

```text
shared-knowledge/
├── corpus/
│   ├── process/
│   ├── languages/
│   ├── protocols/
│   ├── libraries/
│   └── guides/
├── packs/
│   ├── nostr-zig/
│   └── nostr-general/
└── templates/
    └── project-starter/
```

## How `noztr` Should Use It

- Keep `noztr` decisions, build plan, and active guides here.
- Export reusable content into the shared corpus repo.
- Replace copied shared docs in `noztr` with either:
  - pinned imports/snapshots for stability, or
  - references plus a local overlay note when the project diverges.

## What I Need To Create The Separate Project

- target repo name and path
- whether it should be a new git repo or a plain directory first
- whether to use the same `bd` workflow there
- whether shared docs should be copied or symlinked into consumer projects
- approval to create a sibling workspace directory outside `/workspace/projects/noztr`

## Tradeoffs

## Tradeoff T-SKS-001: Separate corpus repo versus keeping the system inside `noztr`

- Context: the knowledge system is useful, but the current repo has active product execution.
- Options:
  - O1: keep shared-corpus work in `noztr`
  - O2: move shared-corpus work to a separate project
- Decision: O2
- Benefits: lower context pollution, cleaner authority boundaries, easier reuse by other repos
- Costs: one more repo to maintain
- Risks: drift between shared corpus and consuming projects
- Mitigations: use review dates, provenance fields, and pinned snapshots in consumers
- Reversal Trigger: if cross-project reuse remains small and the extra repo overhead outweighs value
- Scope Impacted: shared research, shared guides, starter templates
