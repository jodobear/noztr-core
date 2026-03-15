---
title: Implemented NIP Review Guide
doc_type: reference
status: active
owner: noztr
read_when:
  - auditing_implemented_surfaces
  - running_robustness_passes
  - deciding_whether_narrow_behavior_is_justified
depends_on:
  - docs/plans/decision-index.md
  - docs/plans/noztr-sdk-ownership-matrix.md
canonical: true
---

# Implemented NIP Review Guide

Use this guide when reviewing implemented behavior for accidental over-narrowing, trust-boundary
mistakes, or unnecessary ecosystem friction.

## Review Criteria

The standard is not "be permissive". It is "be deterministic, bounded, and compatible unless there
is a concrete reason not to be."

Review axes for every implemented NIP:
- NIP text: what the relevant NIP(s) actually require, permit, or leave open
- real ecosystem prevalence: what widely deployed producers and consumers appear to emit or accept
- `rust-nostr` parity signal: what a strong production reference does in practice and what that
  implies for compatibility confidence
- `nostr-tools` ecosystem signal: what the largest widely used JavaScript library appears to emit
  or accept, used as a secondary non-gating compatibility signal rather than an active release gate
- security / trust-boundary impact: whether acceptance or rejection preserves cryptographic
  validity, typed failures, explicit bounds, deterministic state transitions, zeroization where
  required, and resistance to ambiguity or malformed input
- Zig-native bounded-contract quality: whether the behavior keeps the API explicit, caller-buffer
  first where appropriate, bounded, simple to reason about, and production-useful for both humans
  and LLM agents

Temperament rule for review and implementation:
- apply KISS to protocol behavior as well as code structure
- do not add narrow helper rules, extra typed failures, or special-case parsing unless they produce
  clear trust-boundary, correctness, or interoperability benefit
- when safe, prefer ignoring irrelevant or future-compatible input over poisoning the whole helper
  path
- explicit is good; fussy is not

Cross-cutting review lenses for every implemented NIP:
- compatibility cost versus benefit
- overengineering / unnecessary reinvention
- LLM and human usability

Tracker and landing discipline:
- treat all `br` mutations and all git-writing steps as serial-only operations
- never parallelize `br update/close/create`, `br sync --flush-only`, or any `git commit`
- canonical order when tracker state changes:
  `br update/close/create` -> `br sync --flush-only` -> `git add .beads/` -> `git commit`

| NIP | Review Criteria From `D-036` |
| --- | --- |
| 01 | Preserve hard rejection for cryptographic invalidity and malformed critical fields; review filter-field rejection, lowercase-only critical hex, and relay `OK` status rules to confirm each narrowing is protocol-necessary or materially safer rather than merely tidier. |
| 02 | Preserve kind scoping and pubkey validity; review whether valid relay-hint and petname shapes are accepted without forcing an unnecessarily narrow contact-tag interpretation. |
| 03 | Preserve exact attestation target references, bounded proof decoding, and the accepted local proof floor (magic/version/sha256 root digest/Bitcoin attestation); review proof-shape strictness so we reject malformed `1040` events without pretending to perform deeper networked OpenTimestamps / Bitcoin verification that the kernel does not actually implement. |
| 09 | Preserve author-bound deletion integrity and typed target failures; review whether any accepted `e`/`a` delete shape from the NIP is being rejected without a safety reason. |
| 10 | Preserve deterministic thread extraction and malformed-marker rejection while keeping reviewed compatibility for legacy `mention` tags and four-slot pubkey fallback; review any future narrowing against both ecosystem pressure and whether the extra accepted data actually improves trust-boundary behavior. |
| 11 | Preserve typed known-field validation with unknown-field tolerance; review whether known-field typing or pubkey strictness rejects inputs the NIP intentionally leaves open. |
| 13 | Preserve checked PoW truthfulness and bounded nonce handling; review nonce-tag shape rules only where real producers emit broader but still unambiguous forms. |
| 17 | Preserve bounded kind-`14` message parsing, wrap-to-rumor trust-boundary reuse, and kind-`10050` relay-list extraction; review recipient/reply/subject tag exactness against real producer output without widening the kernel into chat orchestration or kind-`15` file-transfer policy. |
| 18 | Preserve repost target consistency and embedded-event verification; review whether addressable repost/helper shapes accepted in the ecosystem remain deterministic enough for Layer 1. |
| 19 | Preserve exact codec correctness and forbidden-secret handling; review only if bech32 casing or TLV acceptance is broader in practice while still standards-valid. |
| 21 | Preserve deterministic `nostr:` URI parsing; review whether any lowercase-only or boundary-token rule is stricter than the URI/NIP actually requires. |
| 22 | Preserve root/parent/linkage correctness and NIP-73 consistency; review mandatory `K/k`, `P/p`, and root-scope requirements against deployed comment traffic so we do not reject valid-but-common comment structures without strong justification. |
| 23 | Preserve required `d` editability, bounded long-form metadata extraction, and deterministic hashtag ordering; review optional metadata exactness so we reject malformed title/image/summary/published-at tags without turning harmless unknown or future article metadata into whole-helper failures. |
| 24 | Preserve bounded kind-`0` metadata extras parsing and deterministic generic tag handling; review deprecated-field fallback and generic tag breadth so we accept real metadata/tag shapes without partially re-implementing NIP-73-owned `i` grammar in the wrong module. |
| 25 | Preserve target determinism and NIP-30-valid custom emoji handling; review target heuristics and emoji-tag requirements to ensure we reject malformed reactions, not merely unfamiliar but still valid ones. |
| 26 | Preserve exact `delegation` tag shape, supported condition grammar, message-string/signature correctness, and pure event-condition checks; review any future widening only if real producer behavior demonstrates broader but still deterministic condition or hex-tag shapes. |
| 27 | Preserve stable spans and decoded references; review lowercase-only `nostr:` handling and malformed-fragment fallback so URI extraction remains spec-correct without dropping harmless real-world forms. |
| 29 | Preserve bounded relay-generated event parsing and pure fixed-capacity state reduction without embedding load/fetch/subscription logic in the kernel; review compatibility shims such as `public`/`open` metadata aliases only where deployed helper behavior makes them materially useful. |
| 05 | Preserve spec-shaped local-part validation, bare-domain `_` canonicalization, exact well-known URL composition, and bounded `names` / `relays` / `nip46` extraction; review optional-map strictness only where broader ecosystem responses remain deterministic and useful instead of silently widening identifier grammar beyond the NIP. |
| 32 | Preserve bounded kind-`1985` label-event extraction, non-`1985` self-label extraction, and exact `e`/`p`/`a`/`r`/`t` target matching; review namespace/label/tag-item breadth so we ignore unrelated future-compatible tags without accepting malformed supported target tags or drifting into label-management workflow logic. |
| 36 | Preserve exact `content-warning` tag detection/building and the accepted NIP-32 namespace bridge, while reviewing empty-reason and extra-item handling so the helper stays ecosystem-compatible without turning into moderation policy or richer content workflow logic. |
| 37 | Preserve exact kind-`31234` `d`/`k` metadata parsing, blank-content deleted-draft handling, NIP-44 draft/private-relay decryption boundaries, and kind-`10013` private relay-tag extraction; review only where broader deployed draft or private-relay payload shapes remain deterministic and reusable without turning the kernel into draft-sync or editor workflow. |
| 56 | Preserve bounded kind-`1984` report extraction/building, required `p` target presence, typed report enums, and tolerant handling of clearly generic `e`/`p` forms; review note/blob-report exactness so the kernel stays deterministic without pretending to be a moderation-policy engine. |
| 58 | Preserve deterministic badge definition / award / profile-badge parsing and pair validation while keeping unmatched profile display pairs safely ignorable; review optional badge metadata and relay-hint exactness so the kernel stays interoperable without turning into badge presentation or sync workflow logic. |
| 39 | Preserve bounded kind-`10011` claim extraction and deterministic proof material without embedding provider fetch policy in the kernel; review provider/identity/proof validation only where broader real-world forms remain unambiguous and production-useful. |
| 40 | Preserve explicit expiration parsing and typed boundary failures; review only if real traffic uses spec-valid but non-canonical timestamp/tag forms. |
| 42 | Preserve replay safety, origin binding, and typed auth failures; review path binding, `ws`/`wss` distinction, and IPv6 rules against operational interoperability evidence before freezing them as unquestionable defaults. |
| 44 | Preserve cryptographic staging, typed failures, and zeroization; compatibility review is secondary here and should only consider standards-backed variant handling, not permissive decoding. |
| 45 | Preserve bounded extension parsing and state transitions; review whether extension message shapes are being narrowed beyond the extension spec or common peer behavior. |
| 50 | Preserve bounded token parsing and explicit unsupported forms; review whether rejected search-token patterns are malformed or just broader than our current parser. |
| 51 | Preserve set metadata bounds, coordinate-kind checks, and deterministic extraction; review bookmark/list-family narrowing, optional emoji-set coordinates, and future list-shape breadth against both the NIP tables and real producer behavior. |
| 59 | Preserve staged unwrap integrity, sender continuity, and bounded scratch usage; review only if interoperability pressure appears on wrapper/seal/rumor envelope shapes that remain unambiguous and safe. |
| 65 | Preserve relay URL validation, marker typing, and bounded extraction; review normalization and accepted marker breadth so we reject malformed relays rather than merely non-preferred formatting. |
| 70 | Preserve deny-by-default protected-event semantics and exact tag meaning; review whether any tag-shape exactness exceeds what NIP-70 needs for deterministic behavior. |
| 73 | Preserve bounded external-id parse/build/match behavior and shared ownership of generic `i` grammar; review kind/value strictness so we reject malformed external IDs without fragmenting the grammar across per-NIP helper reimplementations. |
| 84 | Preserve deterministic highlight-source extraction, bounded `p` attribution/url-reference parsing, and optional `context`/`comment` handling without drifting into reader UX; review long-form source-tag and role/marker tolerance so the kernel stays interoperable without becoming article/highlight workflow logic. |
| 92 | Preserve exact `imeta` pair parsing, required `url` plus at least one supported metadata field, NIP-94-aligned value validation, repeated fallback support, and URL-to-content matching that rejects prefix-only embeddings; review only where broader deployed `imeta` field handling remains deterministic and does not collapse supported-field trust boundaries into generic string maps. |
| 94 | Preserve exact kind-`1063` parsing, required `url`/lowercase-MIME/`x` handling, bounded optional metadata tags, repeated fallback support, and typed duplicate/malformed-tag failures; review optional field breadth only where broader deployed shapes remain deterministic and do not weaken the trust boundary for core file metadata. |
| 99 | Preserve bounded classified-listing metadata extraction/building for `30402` / `30403`, required `d`, typed price/status handling, ordered image/hashtag support, and ignored unrelated tags; review field exactness only where broader deployed listing metadata remains deterministic and does not pull commerce/search workflow into the kernel. |
| 77 | Preserve bounded negentropy state transitions and strict session parsing; review message-shape rejection only where broader but still well-defined peer behavior exists. |

Review execution rule:
- a behavior is too strict when it creates material ecosystem incompatibility without improving
  correctness, safety, determinism, or boundedness
- a behavior is acceptable to keep narrow when it closes ambiguity, prevents malformed input
  acceptance, or protects a trust boundary in a way that a broader rule cannot
- a divergence from `rust-nostr` is acceptable when it is NIP-grounded, test-backed, bounded, and
  materially improves correctness, determinism, or Zig-native contract quality without causing
  disproportionate ecosystem friction
- a mismatch with `nostr-tools` is a compatibility signal to evaluate, not an automatic defect

Required per-NIP contract discipline:
- freeze a short spec-to-contract checklist before closure
- no NIP closes until every checklist line is mapped to code, tests, examples, or an explicit
  accepted non-goal
- treat builder/parser symmetry as a mandatory closure class where both surfaces exist
- treat public error semantics as a mandatory review class
- when a NIP is `LIB_UNSUPPORTED` or only weakly covered in reference lanes, require one extra
  spec-first challenge pass before closure
- if the review process becomes stricter mid-stream, run a retroactive backfill pass over recently
  closed or newly expanded NIPs touched before the new rule landed

Required adversarial coverage:
- every implemented or newly expanded protocol surface must have happy-path tests, per-field
  negative corpus, and hostile/adversarial inputs where the protocol shape warrants them
- tokenized or sectioned grammars must include nonsense-token and separator-discipline challenges
- boundary-heavy modules must include hostile transcript coverage
- boundary-heavy SDK-facing modules must also expose at least one hostile or invalid example in
  `examples/`

## Implemented NIP Audit Execution

Run the audit serially, one implemented NIP at a time, before further phase expansion work.

Per-NIP audit steps:
1. create or claim one beads audit issue for the NIP and freeze the exact review target
2. gather evidence from the NIP text, current `noztr` code/tests, `rust-nostr`, `nostr-tools`, and
   relevant in-repo ecosystem notes
3. review with the required axes and cross-cutting lenses above
4. record findings only when they are evidence-backed
5. run a second-pass challenge on the draft findings
6. run an adversarial audit pass focused on builder/parser symmetry, public error-contract
   mismatches, hostile transcripts, and checklist lines not yet proven by tests/examples
7. resolve each accepted finding by immediate fix, accepted-risk, follow-up issue, or intentional
   divergence
8. update canonical docs only where policy, accepted behavior, or current status changed; keep the
   remaining evidence in the beads issue and update `docs/plans/implemented-nip-audit-report.md`
9. land one local git commit scoped to the completed audit item
10. close the audit issue only when findings, evidence classes, outcome, and follow-up items are
    all recorded explicitly

Audit quality rules:
- no NIP is audited by vibe or memory only
- no reference library is treated as protocol authority
- no finding is accepted without a severity, evidence basis, and interoperability rationale
- "no issue found" is recorded explicitly when that is the result
- every implemented NIP audit must record both `rust-nostr` and `nostr-tools` evidence status
- every completed audit that changes code or canonical docs must land as its own local git commit
- every completed audit that changes accepted behavior, findings, or current status must update
  `docs/plans/implemented-nip-audit-report.md`

## Implemented Surface Robustness / Real-World Validation Execution

Use this when the goal is to harden already-implemented surfaces before adding more NIPs. This
reuses the implemented-NIP audit standards above and extends them with stronger integration and
interoperability evidence.

Per-surface robustness steps:
1. create or claim one beads issue for the target hardening pass and freeze the exact scope
2. reuse the same review axes, temperament rule, and cross-cutting lenses from the implemented-NIP
   audit
3. gather stronger execution evidence than a normal parity review where practical
4. prefer findings in these classes:
   - latent bug under realistic composition
   - unnecessary interoperability friction under real producer/consumer behavior
   - trust-boundary weakness that only appears in end-to-end or composed flows
   - unnecessary complexity that makes maintenance or safe usage harder than needed
5. keep the fix posture narrow
6. run the same two review-cycle discipline used by the implementation loop
7. add an adversarial hardening pass
8. for boundary-heavy SDK-facing surfaces, ensure `examples/` includes at least one hostile or
   invalid consumer-facing fixture
9. run fresh gates after the final candidate
10. update canonical docs only where accepted behavior, active risks, or current state changed
11. land one local git commit scoped to the completed robustness item before moving to the next one

Robustness pass quality rules:
- reuse existing procedure; do not create a new ad hoc review process per surface
- treat real-world/interoperability evidence as a strengthening layer on top of the audit, not as a
  replacement for the audit standards
- prefer hardening the highest-value, most integration-sensitive surfaces first before resuming new
  protocol expansion
- consult `docs/plans/noztr-sdk-ownership-matrix.md` before widening `noztr` or deferring
  deterministic protocol glue out of it when the question is really kernel-vs-SDK ownership
