# v1 Zig Implementation Notes (Phase C0)

Date: 2026-03-05

Scope: v1 modules only (`nip01_event`, `nip01_filter`, `nip01_message`, `nip42_auth`,
`nip70_protected`, `nip09_delete`, `nip40_expire`, `nip13_pow`, `nip19_bech32`, `nip21_uri`,
`nip02_contacts`, `nip65_relays`, `nip44`, `nip59_wrap`, `nip45_count`, `nip50_search`,
`nip77_negentropy`, `nip11`).

## Decisions

- `C0-001`: implementation contracts prioritize strict deterministic behavior and typed failures.
- `C0-002`: translation from TypeScript/Rust/Zig studies keeps behavior parity, not API-shape parity.
- `C0-003`: runtime memory behavior is fixed-capacity and caller-buffer-owned on hot paths.
- `C0-004`: high-risk Zig footguns are blocked with mandatory safe replacements and forcing tests.

## Translation Notes

### C1 applesauce -> `noztr`

- Keep transcript and state-machine invariants (`REQ/CLOSE/EOSE`, AUTH retry, NEG flow), but
  re-express them as typed unions and explicit bounded state structs.
- Reject RxJS/symbol-cache mutation patterns in core modules; use explicit state fields only.
- Carry over delete author-binding and gift-wrap staged unwrap behavior as policy primitives.
- Convert convenience normalization behavior into optional compatibility adapters only.
- Tighten malformed timestamp/number handling (`NaN`-style tolerance is forbidden in strict mode).

### C2 rust-nostr -> `noztr`

- Keep split verify boundaries (`verify_id`, `verify_signature`, full verify) and strict message
  arity parsing.
- Convert typed domain boundaries into fixed-size Zig structs and explicit error sets.
- Reject heap-first collection defaults (`Vec`, maps, `String`) in runtime contracts.
- Preserve NIP-44 vector-driven validation, but replace non-explicit MAC equality with mandatory
  constant-time compare helper.
- Keep legacy wire-shape handling out of strict default path; allow only explicit compatibility entry.

### C3 libnostr-z -> `noztr`

- Keep module-oriented file boundaries and deterministic ordering invariants.
- Preserve proven parser/crypto check ordering where behavior is parity-critical.
- Reject dependency/runtime assumptions (C crypto backends, external string libs, allocator-heavy
  hot paths).
- Replace permissive parse behavior with typed strict failures in default profile.
- Keep optional NIPs isolated from core parser semantics via explicit extension module boundaries.

## Source-to-Module Translation Matrix

| Module | C1 applesauce transfer | C2 rust-nostr transfer | C3 libnostr-z transfer |
| --- | --- | --- | --- |
| `nip01_event` | keep replaceable/delete invariants | keep split verify APIs | keep deterministic tie-break ordering |
| `nip01_filter` | strict core + optional search path | reject malformed `#` keys in strict mode | preserve AND/OR semantics with fixed bounds |
| `nip01_message` | transcript-state invariants | typed message enum + arity checks | keep canonical wire verb set |
| `nip42_auth` | challenge retry/state flow | pure auth predicate with typed reasons | relay/challenge validation boundary |
| `nip70_protected` | tag detection plus relay policy split | keep event-tag detection split | default deny without auth context |
| `nip09_delete` | author-bound deletion behavior | avoid builder-only modeling | fill policy gap with explicit checks |
| `nip40_expire` | reject malformed expiration | parse tag then pure check helper | keep presence semantics, strict parse failures |
| `nip13_pow` | standalone deterministic validator | preserve leading-zero primitive | keep missing-commitment semantics |
| `nip19_bech32` | avoid convenience normalization in strict path | typed entity decode model | preserve checksum/mixed-case rejects |
| `nip21_uri` | do not use regex-only mention parsing | strict `nostr:` + unsupported variant errors | preserve `nsec` reject policy |
| `nip02_contacts` | strict kind-3 `p` extraction only | explicit malformed-pubkey errors | implement missing dedicated module |
| `nip65_relays` | marker semantics + normalization boundaries | typed marker model | strict marker and URL validation |
| `nip44` | reimplement in stdlib-only kernel | preserve vector corpus and check order | preserve decrypt gate ordering |
| `nip59_wrap` | staged unwrap + parent/sender integrity | sender mismatch spoof rejection | preserve unwrap order invariants |
| `nip45_count` | transcript correlation and timeout semantics | typed COUNT grammar | add strict optional metadata validation |
| `nip50_search` | extension-only semantics | explicit opt-in gate model | keep isolated extension parser |
| `nip77_negentropy` | keep NEG state machine behavior | strict canonical open shape default | preserve ordering and mode flow |
| `nip11` | n/a | n/a | partial-doc acceptance + known-field type checks |

## Coding Agent Review Checklist (Required)

Use this checklist before marking any module complete.

- Function shape:
  - max 70 lines; max 100 columns.
  - minimum 2 assertions with positive and negative space coverage.
- Memory and bounds:
  - no post-init dynamic allocation on runtime path.
  - fixed-capacity buffers; all variable fields carry explicit max checks.
  - all protocol fields use explicit-width integers (no `usize` in wire/state contracts).
- Errors and control flow:
  - no broad error funnels; public APIs expose typed failure variants.
  - no compound condition trees that hide branch-specific errors.
  - no bool-only boundary validators where typed error is needed.
- Crypto and secrecy:
  - NIP-44 uses constant-time MAC compare.
  - temporary secrets are wiped on all return paths with `defer`.
  - decrypt flow order is length -> version -> MAC -> decrypt -> padding.
- Determinism and parity:
  - canonical serialization is the only hash/signing input path.
  - ordering invariants (replaceable tie-break, negentropy sort) are covered by vectors.
  - strict profile and compatibility profile are separated by explicit entry points.
- Test coverage:
  - happy path and invalid path tests present for each public function.
  - each public error variant has a forcing test.
  - optional NIPs include minimum valid/invalid vector cases per Phase B defaults.

## Ambiguity Checkpoint

`A-C0-001`
- Topic: strict vs compatibility entry-point organization (`single module` vs `compat namespace`).
- Impact: medium.
- Status: accepted-risk.
- Default: keep strict entry points as canonical APIs; compatibility lives in explicit sibling APIs.
- Owner: active phase owner.

`A-C0-002`
- Topic: depth of first-pass NIP-77 implementation (framing-first vs optimization-first).
- Impact: medium.
- Status: accepted-risk.
- Default: framing/state correctness first, optimization later.
- Owner: active phase owner.

`A-C0-003`
- Topic: strict optional metadata default for `nip45_count` (`approximate`, `hll`).
- Impact: low.
- Status: resolved.
- Default: keep strict parser hooks now; finalize vector depth in Phase D.
- Owner: active phase owner.

Ambiguity checkpoint result: high-impact `decision-needed` count = 0.

## Tradeoffs

## Tradeoff T-C0-004: Single strict path versus dual strict/compat entry points

- Context: strict defaults need deterministic behavior, but ecosystem replay may need compatibility.
- Options:
  - O1: one parser path with internal permissive branches.
  - O2: strict canonical entry points plus explicit compatibility entry points.
- Decision: O2.
- Benefits: explicit behavior contracts and easier test isolation.
- Costs: larger API surface.
- Risks: duplicated validation logic.
- Mitigations: share internal helpers with explicit mode adapters at boundaries.
- Reversal Trigger: measurable maintenance burden from duplicated paths exceeds safety gains.
- Principles Impacted: P01, P03, P05, P06.
- Scope Impacted: `nip01_filter`, `nip19_bech32`, `nip77_negentropy`, `nip11`.

## Tradeoff T-C0-005: Fixed-capacity runtime contracts versus allocator-driven ergonomics

- Context: allocator-driven APIs are easier to consume but weaken bounded runtime guarantees.
- Options:
  - O1: allocator-return APIs in core runtime boundaries.
  - O2: caller-owned buffer APIs for encode/decode/crypto runtime boundaries.
- Decision: O2.
- Benefits: bounded memory, clear ownership, deterministic failure modes.
- Costs: more buffer sizing responsibility at call sites.
- Risks: frequent `BufferTooSmall` integration mistakes.
- Mitigations: expose max-size constants and add boundary forcing tests.
- Reversal Trigger: evidence of unacceptable usability cost without safety gain.
- Principles Impacted: P02, P05, P06.
- Scope Impacted: `nip01_event`, `nip01_message`, `nip19_bech32`, `nip44`, `nip59_wrap`.

## Tradeoff T-C0-006: Strict malformed-data rejection versus permissive normalization

- Context: external studies show permissive handling patterns for malformed-but-common data.
- Options:
  - O1: normalize malformed data in strict path.
  - O2: strict reject malformed data; provide optional compatibility adapters.
- Decision: O2.
- Benefits: deterministic trust boundaries and stronger integrity guarantees.
- Costs: compatibility adapters needed for non-conformant ecosystems.
- Risks: interop friction during migration.
- Mitigations: keep adapter behavior explicit, documented, and test-backed.
- Reversal Trigger: standards-backed parity requirement cannot be met under strict default.
- Principles Impacted: P01, P03, P05, P06.
- Scope Impacted: `nip01_event`, `nip40_expire`, `nip19_bech32`, `nip65_relays`, `nip77_negentropy`.

## Open Questions

- `OQ-C0-001`: confirm in Phase C4 whether compatibility APIs will be co-located per module or
  grouped under `compat/*` wrappers (status: accepted-risk).
- `OQ-C0-002`: confirm in Phase D whether optional-module invalid corpora need stricter minimums for
  `nip77_negentropy` beyond current Phase B baseline (status: accepted-risk).

## Principles Compliance

- Required sections present: `Decisions`, `Tradeoffs`, `Open Questions`, `Principles Compliance`.
- `P01`: strict validation order and typed failures are preserved across trust boundaries.
- `P02`: design remains protocol-kernel oriented with stdlib-only bounded runtime contracts.
- `P03`: behavior parity from C1/C2/C3 is translated into enforceable Zig module constraints.
- `P04`: auth/protected/relay semantics stay explicit and auditable.
- `P05`: deterministic serialization, ordering, and transcript behavior are required and test-backed.
- `P06`: fixed-capacity memory and bounded work rules are explicit and review-checkable.
