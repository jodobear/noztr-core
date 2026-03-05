# v1 Implementation Decisions (Phase C4)

Date: 2026-03-05

Scope: synthesis of Phase C1/C2/C3 findings into one implementation decision baseline for all
v1 modules.

## Decisions

- `C4-001`: default profile remains strict and deterministic for all trust-boundary parse/verify
  paths; compatibility behavior is explicit opt-in only and never implicit.
- `C4-002`: public runtime APIs remain caller-buffer-first with fixed-capacity state; no post-init
  dynamic allocation on runtime paths.
- `C4-003`: `nip01_event` is the canonical host for moved NIP semantics (12/16/20/33 linkage);
  replaceable/addressable ordering is deterministic (`created_at`, then lexical `id`).
- `C4-004`: relay transcript grammar is modeled with typed unions and exact arity/type checks;
  extension verbs are isolated and must not mutate core parser defaults.
- `C4-005`: auth/protected policy remains split (`nip42_auth` validation + `nip70_protected`
  acceptance gate) with default deny for protected events absent valid auth context.
- `C4-006`: `nip44` and `nip59_wrap` preserve algorithm/check-order parity from studies, but are
  reimplemented stdlib-only with constant-time MAC comparison and secret wiping.
- `C4-007`: optional modules (`nip19_bech32`, `nip21_uri`, `nip02_contacts`, `nip65_relays`,
  `nip45_count`, `nip50_search`, `nip77_negentropy`) stay isolated with strict typed boundaries and
  explicit feature gates.
- `C4-008`: conflicts across C1/C2/C3 are resolved in this artifact; no high-impact ambiguity
  remains `decision-needed` at C4 closure.

## Module-Level Decision Matrix

| Module | Final choice | Source synthesis (C1/C2/C3) | Enforceable implementation commitment | Edge-case handling commitment |
| --- | --- | --- | --- | --- |
| `nip01_event` | Adopt + Adapt | C1 author/delete/replaceable semantics; C2 split verify APIs; C3 deterministic ordering | Keep `verify_id`, `verify_signature`, `verify`; canonical serialization only for id; strict lowercase fixed-length hex | Reject duplicate critical keys; reject invalid id/sig/pubkey; tie-break equal `created_at` by lexical `id` |
| `nip01_filter` | Adapt | C1 extension bleed warning; C2 strict malformed `#x` handling; C3 fixed-bound parser recommendation | Strict NIP-01 field parser with typed errors; optional fields routed to extension modules only | Reject invalid `#` key shapes; enforce bounds for ids/authors/tags; enforce `since <= until` |
| `nip01_message` | Adopt + Adapt | C1 transcript invariants; C2 typed enum grammar; C3 canonical verb set | Typed client/relay union grammar with exact array arity checks and strict unknown-command rejection | Enforce `REQ -> EVENT* -> EOSE -> CLOSE` transcript state; reject malformed `OK/CLOSED` reason shapes |
| `nip42_auth` | Adopt | C1 challenge retry/state; C2 pure validator model; C3 relay/challenge extraction boundary | Pure auth validator with typed failures; bounded challenge state and timestamp window checks | Reject wrong kind; reject relay mismatch; reject challenge mismatch; reject stale timestamp |
| `nip70_protected` | Adopt | C1/C2/C3 all support tag-detection + policy split | Detect protected tag shape separately from policy; default deny unless authenticated pubkey matches author | Accept only exact `['-']`; reject unauthenticated protected events; reject auth pubkey mismatch |
| `nip09_delete` | Adapt | C1 full author-bound delete behavior; C2/C3 policy gap noted | Dedicated policy validator for `e`/`a` references with author binding and timestamp constraints | Reject empty target sets; reject cross-author delete effect; enforce address-delete `created_at` bound |
| `nip40_expire` | Adapt | C1 `NaN`-style pitfall; C2 pure helper model; C3 strict parse requirement | Parse expiration tags strictly, then evaluate via pure boundary helper | Reject malformed expiration integer; boundary second is non-expired at equality then expired after |
| `nip13_pow` | Adapt | C1 missing dedicated module; C2 leading-zero primitive; C3 nonce-tag behavior | Standalone deterministic leading-zero validator with strict nonce-tag parsing | Reject malformed nonce tags; allow missing nonce commitment value without inferred target; fail unmet difficulty |
| `nip19_bech32` | Adapt | C1 normalization caution; C2 typed entity model; C3 checksum/mixed-case behavior | Strict HRP dispatch, bounded TLV parser, required field enforcement; unknown TLVs ignored | Reject bad checksum/mixed case; reject malformed known optional TLVs when present; reject required TLV absence |
| `nip21_uri` | Adopt + Adapt | C1 regex-only rejection; C2 strict `nostr:` parser; C3 `nsec` deny behavior | Dedicated strict URI parser wrapping strict NIP-19 decode; no regex-only acceptance path | Reject non-`nostr:` scheme; reject `nostr:nsec...`; reject invalid embedded NIP-19 |
| `nip02_contacts` | Adapt | C1 public-only extraction; C2 typed pubkey errors; C3 dedicated module gap | Kind-3 `p`-tag extraction API with bounded outputs and explicit typed failures | Reject non-`p` tags in strict extraction path; reject malformed pubkeys; enforce output-capacity failures |
| `nip65_relays` | Adapt | C1 marker + normalization; C2 typed marker/url model; C3 strict marker requirement | Strict marker parser (`read`, `write`, empty only) and typed URL validation boundary | Reject unknown marker tokens; reject malformed URLs; preserve deterministic dedupe ordering |
| `nip44` | Adopt + Adapt | C1 local stdlib implementation need; C2 vector/check-order transfer + constant-time gap; C3 check-order parity with backend rejection | Implement NIP-44 v2 stdlib-only, staged checks (`len -> version -> MAC -> decrypt -> padding`), caller buffers, secret wipe | Reject unsupported `#` encoding; reject invalid version/MAC/padding/length ranges; constant-time MAC compare |
| `nip59_wrap` | Adopt + Adapt | C1 staged unwrap + integrity; C2 spoofing test behavior; C3 unwrap order invariants | Strict staged unwrap (`wrap -> seal -> rumor`) with signature checks and sender consistency checks | Reject wrong outer kind; reject invalid seal sig; reject sender mismatch spoof; reject malformed rumor |
| `nip45_count` | Adapt | C1 id-correlation flow; C2 typed COUNT grammar; C3 metadata-depth gap | Strict COUNT message grammar with optional metadata validators kept explicit and bounded | Reject malformed count object; reject invalid `hll` hex length/format; preserve `CLOSED` unsupported flow |
| `nip50_search` | Adapt | C1 DB-coupling rejection; C2 opt-in gate model; C3 extension isolation | Extension-only parser path and explicit gate; core filter parser remains unchanged by default | Reject non-string search values; ignore unsupported `key:value` extension tokens per policy |
| `nip77_negentropy` | Adapt | C1 full NEG flow and error semantics; C2 strict default shape with explicit legacy compat; C3 ordering/state invariants | Strict NEG family parser with bounded session state and canonical v1 open shape; legacy shape only in compat API | Reject malformed hex framing; reject unsupported protocol version with typed response path; preserve timestamp/id ordering |
| `nip11` | Adapt | C3 partial-doc parser baseline + known-type checks; protocol reference strictness | Partial-document acceptance with strict known-field type validation and bounded structured parsing | Ignore unknown fields; reject known-field type mismatches; reject malformed structured known objects |

## Conflict Resolution (C1/C2/C3)

| Conflict ID | Topic | C1 | C2 | C3 | Resolution |
| --- | --- | --- | --- | --- | --- |
| `C4-CF-001` | Strict vs convenience parsing in core | favors strict kernel adapters | favors strict default + compat branch | favors strict default + compat branch | Resolved: strict-by-default core + explicit compatibility APIs only (`C4-001`). |
| `C4-CF-002` | NIP-19 optional TLV malformed behavior | warns against broad normalization | reject malformed known optional TLV | strict required/optional validation | Resolved: ignore unknown TLV types; reject present malformed known optional TLVs in strict mode. |
| `C4-CF-003` | NEG-OPEN legacy shape acceptance | framing-first focus | legacy shape only behind compat | strict canonical shape in default | Resolved: canonical v1 shape only in strict API; legacy shape explicit compat path. |
| `C4-CF-004` | NIP-45 metadata depth (`approximate`, `hll`) | include hooks, vector depth later | include typed hooks, depth later | include typed hooks, depth later | Resolved: keep strict metadata validators in module contract; Phase D finalizes vector depth gate. |
| `C4-CF-005` | Crypto backend reuse | reject dependency delegation | keep flow, replace memory/compare mechanics | keep flow, reject external backend/runtime | Resolved: stdlib-only implementation preserving behavior/vector parity; no backend parity target. |

## Risk and Mitigation Register

| Risk ID | Risk | Impact | Likelihood | Mitigation | Owner |
| --- | --- | --- | --- | --- | --- |
| `R-C4-001` | Strict defaults may reject permissive ecosystem inputs | medium | medium | Keep explicit compat entry points with separate vectors and naming | Phase D owner |
| `R-C4-002` | NIP-44 implementation drift from reference vectors | high | medium | Pin official vectors and enforce full valid/invalid parity in Phase D | Phase D owner |
| `R-C4-003` | Optional-module drift due to lower test pressure | medium | medium | Enforce Phase B minimum optional vectors and extension gate tests | Phase D owner |
| `R-C4-004` | Bounded-state limits may undersize real-world transcripts | medium | low | Publish explicit limits constants and force `BufferTooSmall`/`TooManyItems` tests | Phase D owner |
| `R-C4-005` | Compatibility pathways could leak into strict path over time | high | low | Keep strict and compat entry points separate and test for non-interference | Phase D owner |

## Forward-Lane Note for Phase D Contracts

Accepted extension-lane items from `docs/plans/v1-additional-nips-roadmap.md` are recorded for
Phase D contract codification only and do not alter v1 scope freeze:

- H2 Wave 1 contract-prep candidates: NIPs `06`, `46`, `51`, `10`, `25`.
- H2 Wave 2 contract-prep candidates: NIPs `18`, `22`, `23`, `27`, `36`, `48`, `56`, `58`, `98`,
  `99`.
- H3 defer/monitor lane references retained for planning context only: NIPs `03`, `14`, `24`, `26`,
  `30`, `31`, `32`, `38`, `39`, `41`, `52`, `53`, `57`, `60`, `61`.
- H3 rejected hold remains unchanged: NIPs `07`, `08`, `47`, `55`.

Phase D must represent these as extension-lane contract placeholders and gating notes only, with no
promotion into current v1 implementation scope.

## Tradeoffs

## Tradeoff T-C4-001: Strict-default core versus permissive-default core

- Context: C1/C2/C3 show interop pressure for permissive parsing but policy defaults require strictness.
- Options:
  - O1: strict default core with explicit compatibility entry points.
  - O2: permissive default core with strict mode opt-in.
- Decision: O1.
- Benefits: deterministic trust boundaries and stable error contracts.
- Costs: additional compatibility API and test maintenance.
- Risks: early integration friction on malformed ecosystem data.
- Mitigations: compat modules are explicit and vector-backed.
- Reversal Trigger: high-value interop cannot be met without permissive default behavior.
- Principles Impacted: P01, P03, P05, P06.
- Scope Impacted: all v1 parser/validator modules.

## Tradeoff T-C4-002: One mixed parser surface versus strict/compat split surfaces

- Context: mixed parser surfaces reduce API count but allow policy leakage.
- Options:
  - O1: mixed parser behavior behind one API.
  - O2: strict API and compatibility API split.
- Decision: O2.
- Benefits: explicit contracts and easier non-regression testing.
- Costs: larger exported API footprint.
- Risks: duplicated parse helpers.
- Mitigations: shared internal staged helpers with thin boundary wrappers.
- Reversal Trigger: proven maintenance burden without safety/interop benefit.
- Principles Impacted: P01, P03, P05.
- Scope Impacted: `nip01_filter`, `nip19_bech32`, `nip77_negentropy`, `nip11`.

## Tradeoff T-C4-003: Full behavior parity including runtime mechanics versus behavior-only parity

- Context: source projects use runtime/dependency models outside noztr constraints.
- Options:
  - O1: match behavior and runtime mechanics.
  - O2: match behavior and vectors only; keep Zig-native runtime model.
- Decision: O2.
- Benefits: preserves parity goals while honoring static/bounded policy.
- Costs: translation complexity and more contract work.
- Risks: subtle behavioral drift in translation.
- Mitigations: module-level forcing vectors and staged-check contracts.
- Reversal Trigger: repeated parity failures tied to rejected runtime assumptions.
- Principles Impacted: P02, P03, P05, P06.
- Scope Impacted: all modules, especially `nip44`, `nip59_wrap`, `nip77_negentropy`.

## Tradeoff T-C4-004: Optional-module isolation versus core-parser embedding

- Context: optional channels increase interop but can destabilize core behavior if embedded.
- Options:
  - O1: integrate optional fields/verbs into core parser by default.
  - O2: isolate optional modules with explicit feature gates.
- Decision: O2.
- Benefits: stable core contracts and bounded extension complexity.
- Costs: additional module wiring and gate testing.
- Risks: optional profile divergence.
- Mitigations: minimum vector gates and extension boundary tests.
- Reversal Trigger: repeated evidence that isolated modules block required parity outcomes.
- Principles Impacted: P02, P03, P05, P06.
- Scope Impacted: `nip45_count`, `nip50_search`, `nip77_negentropy`, `nip19_bech32`, `nip21_uri`.

## Tradeoff T-C4-005: Pure auth validator with typed failures versus bool-only acceptance check

- Context: bool-only auth answers simplify call sites but hide failure cause.
- Options:
  - O1: bool-only auth predicate.
  - O2: typed auth failure contracts and explicit state checks.
- Decision: O2.
- Benefits: auditable auth failure handling and deterministic relay responses.
- Costs: larger error taxonomy.
- Risks: mapping complexity in message layer.
- Mitigations: explicit failure-to-prefix mapping tests in transcript vectors.
- Reversal Trigger: typed failures provide no operational/debug value in practice.
- Principles Impacted: P01, P04, P05.
- Scope Impacted: `nip42_auth`, `nip70_protected`, `nip01_message`.

## Tradeoff T-C4-006: NIP-44 backend reuse versus stdlib-only reimplementation

- Context: reference implementations rely on external crypto/runtime stacks.
- Options:
  - O1: reuse external crypto/backend dependencies.
  - O2: stdlib-only implementation preserving algorithm order and vectors.
- Decision: O2.
- Benefits: dependency policy compliance and deterministic local control of error paths.
- Costs: increased implementation and review burden.
- Risks: cryptographic implementation mistakes.
- Mitigations: pinned vectors, invalid corpora, constant-time and wipe tests.
- Reversal Trigger: inability to achieve conformance/performance under stdlib-only constraints.
- Principles Impacted: P01, P05, P06.
- Scope Impacted: `nip44`, `nip59_wrap`.

## Tradeoff T-C4-007: Strict malformed-known-optional TLV rejection versus permissive drop

- Context: unknown TLVs should be forward-compatible, but malformed known optionals reduce integrity.
- Options:
  - O1: ignore malformed known optional TLVs.
  - O2: reject malformed known optional TLVs when present.
- Decision: O2.
- Benefits: stronger typed integrity while preserving unknown-type forward compatibility.
- Costs: stricter behavior than permissive peers.
- Risks: interop friction on bad ecosystem payloads.
- Mitigations: explicit compatibility adapter path for permissive replay.
- Reversal Trigger: standards-backed requirement mandates permissive known-optional handling.
- Principles Impacted: P01, P03, P05.
- Scope Impacted: `nip19_bech32`, `nip21_uri`.

## Tradeoff T-C4-008: C4 closure now versus deferring closure until Phase D vector finalization

- Context: C4 defines architecture synthesis while Phase D defines full contracts/vectors.
- Options:
  - O1: close C4 with resolved architecture decisions and bounded accepted-risk items.
  - O2: keep C4 open until all vector-depth questions are settled.
- Decision: O1.
- Benefits: keeps phase gating flow intact and unblocks contract work.
- Costs: some medium-impact details remain accepted-risk until Phase D.
- Risks: late vector-depth changes may require minor contract edits.
- Mitigations: record explicit accepted-risk items and carry them into Phase D entry criteria.
- Reversal Trigger: new high-impact ambiguity emerges before Phase D contract freeze.
- Principles Impacted: P03, P05, P06.
- Scope Impacted: C4 closure, D-phase planning handoff.

## Unresolved Decisions

- `UD-C4-001` Topic: optional NIP vector depth sufficiency beyond current minimums.
  - Impact: medium.
  - Status: accepted-risk.
  - Default: carry forward Phase B minimum gate (`3 valid + 3 invalid`) and re-evaluate in Phase D.
  - Owner: Phase D owner.
- `UD-C4-002` Topic: compatibility API placement style (`co-located` vs `compat/` namespace).
  - Impact: low.
  - Status: accepted-risk.
  - Default: keep strict APIs canonical; choose final placement during Phase D contract shaping.
  - Owner: Phase D owner.

## Ambiguity Checkpoint

| ID | Topic | Impact | Status | Default | Owner |
| --- | --- | --- | --- | --- | --- |
| `A-C4-001` | optional-module vector-depth threshold | medium | accepted-risk | keep Phase B baseline, tighten only with corpus evidence | Phase D owner |
| `A-C4-002` | compatibility API namespace placement | low | accepted-risk | strict canonical API + explicit compat split remains mandatory | Phase D owner |
| `A-C4-003` | NIP-45 metadata strictness defaults in first contract set | medium | resolved | keep typed metadata validators and strict malformed rejection | Phase D owner |

Ambiguity checkpoint result: high-impact `decision-needed` count = 0.

## Open Questions

- `OQ-C4-001`: Determine in Phase D whether optional module vector minimums should increase above
  `3 valid + 3 invalid` for `nip77_negentropy` and `nip45_count` based on corpus diversity.
- `OQ-C4-002`: Determine in Phase D whether compatibility entry points should be physically grouped
  under `compat/*` while retaining identical strict-default behavior.

## Principles Compliance

- Required sections present: `Decisions`, `Tradeoffs`, `Open Questions`, `Principles Compliance`.
- `P01`: strict trust-boundary validation remains default across event/auth/protected/crypto modules.
- `P02`: architecture remains protocol-kernel and transport-agnostic with optional extension isolation.
- `P03`: synthesis resolves C1/C2/C3 conflicts into one behavior-parity implementation baseline.
- `P04`: relay/auth/protected gating remains explicit and auditable (`nip42_auth`, `nip70_protected`).
- `P05`: deterministic parsing, ordering, transcript handling, and crypto check ordering are enforced.
- `P06`: bounded memory/work posture is preserved via caller-owned buffers and fixed-capacity state.
- Phase gate check: no high-impact ambiguity remains in `decision-needed` status.
