# v1 Additional NIPs Roadmap Addendum (Phase A/B Extension)

Date: 2026-03-05

Supersession note (2026-03-10): active additional-NIP execution planning now lives in
`docs/plans/phase-h-kickoff.md` and `docs/plans/phase-h-additional-nips-plan.md`. NIP-06
build-vs-buy is resolved by `D-030` in favor of a vetted `libwally-core` boundary.

## Decisions

- `X-001`: this addendum records user-requested extra NIP scope evaluation as a post-v1 extension lane
  using existing scope vocabulary only (`parity-core`, `parity-optional`, `expansion-candidate`,
  `defer`, `rejected`).
- `X-002`: all requested NIPs in this addendum are sequenced in H2/H3 only; no new H1 scope is
  introduced.
- `X-003`: provisional note: this addendum does not change frozen defaults `D-001`..`D-004` and
  does not retroactively alter Phase A/B closure evidence.
- `X-004`: NIP-41 planning default remains provisional and deferred to H3 while tracking PR #829 as
  the technical reference and PR #1056 as a secondary policy-direction input.

## Priority Notes (User-Marked Very Important)

- Very important NIPs were explicitly reviewed even where outcome remains `defer` or `rejected`:
  `03`, `06`, `07`, `46`, `47`, `51`, `55`, `57`, `60`, `61`, and `41` (PR `#829`/`#1056`).
- Priority does not override current classification evidence; it increases sequencing visibility and
  revisit priority in H2/H3 planning checkpoints.
- Priority-ranked expansion-candidates for earliest H2 analysis wave are `06`, `46`, and `51`.

## Feature Matrix

| NIP | Horizon | Classification | Rationale |
| --- | --- | --- | --- |
| 03 | H3 | defer | Open timestamp proof utility is recognized, but deterministic verification scope is not yet bounded for near-term extension delivery. |
| 06 | H2 | expansion-candidate | Mnemonic/BIP39/BIP32 key-derivation behavior is wallet and key-lifecycle scope; it remains an H2 expansion-candidate for bounded key-management primitives rather than core event transport semantics, with a mandatory H2 build-vs-buy checkpoint before implementation. |
| 07 | H3 | rejected | NIP-07 defines `window.nostr` browser runtime capability integration, which is intentionally out-of-scope for this low-level core protocol library. |
| 08 | H3 | rejected | NIP-08 is a mention-handling convention for client content/reference behavior and is therefore outside this repository's protocol-kernel scope. |
| 10 | H2 | expansion-candidate | Thread/reply relationship conventions improve interoperability and fit bounded parser/validator primitives. |
| 14 | H3 | defer | Subject tagging is useful but not yet prioritized over higher-signal protocol extensions in H2. |
| 18 | H2 | expansion-candidate | Repost semantics are common ecosystem behavior and can be implemented as deterministic event validation helpers. |
| 22 | H2 | expansion-candidate | Comment semantics are broadly useful and map cleanly to explicit event/tag validation rules. |
| 23 | H2 | expansion-candidate | Long-form content metadata can be supported with bounded field handling and strict validation strategy. |
| 24 | H3 | defer | Extra metadata conventions are non-blocking and better sequenced after higher-impact extension contracts. |
| 25 | H2 | expansion-candidate | Reaction event semantics are high-interoperability primitives that remain protocol-layer compatible. |
| 26 | H3 | defer | Delegated event signing needs additional trust-boundary analysis before inclusion in extension contracts. |
| 27 | H2 | expansion-candidate | Text-note references and linking behavior align with deterministic parsing and bounded validation rules. |
| 30 | H3 | defer | Custom emoji metadata is ecosystem-useful but lower protocol criticality than current H2 candidates. |
| 31 | H3 | defer | NIP-31 standardizes unknown-kind fallback via the `alt` tag convention; behavior is known but remains deferred until fallback handling is scheduled in a later extension wave. |
| 32 | H3 | defer | Labeling metadata has policy interpretation ambiguity and is deferred until deterministic contract shape is tighter. |
| 36 | H2 | expansion-candidate | Sensitive-content signaling is interoperable and can be represented as explicit, bounded tag validation. |
| 38 | H3 | defer | User status semantics are useful but not prioritized against higher-value extension compatibility targets. |
| 39 | H3 | defer | External identity claim pathways introduce external trust-policy surface that is intentionally postponed. |
| 41 | H3 | defer | Provisional: PR #829 (`41.md`, kinds 1776/1777) is deterministic in shape but unmerged and tied to NIP-03-style proof verification scope; PR #1056 remains draft and policy-leaning. |
| 46 | H2 | expansion-candidate | Nostr remote signing flow is strategically important and can be modeled with explicit message and verification boundaries. |
| 47 | H3 | rejected | Wallet-connect scope is app/service orchestration heavy and outside the current low-level protocol kernel target. |
| 48 | H2 | expansion-candidate | Proxy tagging conventions are implementable as bounded metadata semantics with clear validation paths. |
| 51 | H2 | expansion-candidate | Lists and categorized collections are high-value interoperability primitives with deterministic event encoding expectations. |
| 52 | H3 | defer | Calendar event model increases domain surface and is deferred pending narrower extension milestone completion. |
| 53 | H3 | defer | Live activity semantics add lifecycle complexity and are postponed behind simpler extension contracts. |
| 55 | H3 | rejected | Android signer app convention is platform-specific integration surface, not a protocol-kernel responsibility. |
| 56 | H2 | expansion-candidate | Reporting semantics can be represented via strict event/tag rules without introducing unbounded runtime behavior. |
| 57 | H3 | defer | Lightning zaps introduce payment request/receipt verification and trust-integration complexity, so support remains deferred pending tighter deterministic payment-boundary contracts. |
| 58 | H2 | expansion-candidate | Badge/profile award semantics are common ecosystem primitives and fit bounded extension parsing contracts. |
| 60 | H3 | defer | Cashu wallet token behavior adds financial workflow complexity beyond current extension priority. |
| 61 | H3 | defer | Nutzap behavior depends on broader ecash/payment conventions and is deferred for later policy-stable sequencing. |
| 98 | H2 | expansion-candidate | HTTP auth event flow is protocol-adjacent and can be added with explicit signature and challenge validation contracts. |
| 99 | H2 | expansion-candidate | Classified listings semantics provide structured event utility while remaining compatible with deterministic bounded processing. |

## Implementation Roadmap

- Pre-wave checkpoint (required before H2 Wave 1 starts):
  - NIP-06 dependency strategy decision (`in-house` vs `vetted helper/wrapper`) must be documented.
  - acceptance criteria for BIP39/BIP32 correctness, security burden, corpus depth, and boundary
    contracts must be approved.
  - unresolved status is `decision-needed` and blocks NIP-06 implementation start.
- Wave 1 (H2, priority expansion-candidates): `06`, `46`, `51`, `10`, `25`.
- Wave 2 (H2, remaining expansion-candidates): `18`, `22`, `23`, `27`, `36`, `48`, `56`, `58`,
  `98`, `99`.
- Wave 3 (H3, defer lane + provisional monitoring): `03`, `14`, `24`, `26`, `30`, `31`, `32`,
  `38`, `39`, `41`, `52`, `53`, `57`, `60`, `61`.
- Wave 4 (H3, rejected hold): `07`, `08`, `47`, `55` remain out-of-scope unless formal reversal
  trigger evidence is documented.

## Tradeoffs

## Tradeoff T-X-001: Prioritize interoperable extension semantics over broad feature volume

- Context: requested NIP set is broad and cannot be safely implemented at once without raising
  ambiguity and contract instability.
- Options:
  - O1: prioritize a smaller H2 set of high-interoperability expansion-candidates first.
  - O2: start all expansion-candidates in parallel.
- Decision: O1.
- Benefits: tighter validation scope, faster contract convergence, lower implementation risk.
- Costs: slower time-to-coverage for lower-priority requested items.
- Risks: stakeholders may perceive sequencing as under-serving less prioritized requests.
- Mitigations: maintain explicit wave ordering and periodic re-evaluation at phase checkpoints.
- Reversal Trigger: evidence that parallelizing more candidates yields equal quality with no
  schedule or stability regression.
- Principles Impacted: P03, P05, P06.
- Scope Impacted: H2 extension ordering for NIPs 06/10/18/22/23/25/27/36/46/48/51/56/58/98/99.

## Tradeoff T-X-002: Keep payment/ecash-oriented NIPs deferred despite priority interest

- Context: user-priority includes `57`, `60`, and `61`, but these introduce policy-heavy financial
  semantics beyond current deterministic core-extension contracts.
- Options:
  - O1: defer payment/ecash-oriented NIPs to H3 pending stronger deterministic contract boundaries.
  - O2: elevate payment/ecash-oriented NIPs into H2 due to user priority.
- Decision: O1.
- Benefits: protects protocol-kernel focus and reduces premature policy coupling.
- Costs: delays direct support for a visible ecosystem feature area.
- Risks: downstream integrators may implement inconsistent external adapters earlier.
- Mitigations: record these NIPs as high-visibility defer items with explicit revisit in C4/D.
- Reversal Trigger: stable, testable contract definitions emerge with bounded validation behavior and
  strong parity evidence.
- Principles Impacted: P02, P03, P05, P06.
- Scope Impacted: NIPs 57/60/61 roadmap placement and Phase D contract priorities.

## Tradeoff T-X-003: Track NIP-41 via PR #829 reference while deferring implementation

- Context: NIP-41 is unmerged, with PR #829 offering a deterministic protocol direction and PR #1056
  offering a more policy-oriented draft alternative.
- Options:
  - O1: adopt PR #829 semantics immediately and implement now.
  - O2: defer implementation, track PR #829 as provisional reference, monitor PR #1056 divergence.
  - O3: reject NIP-41 planning until a merged final spec exists.
- Decision: O2.
- Benefits: preserves technical readiness without locking the codebase to an unstable draft.
- Costs: no immediate implementation output for key migration/revocation workflows.
- Risks: late spec shifts could still require roadmap adjustments.
- Mitigations: keep NIP-41 in defer wave with explicit proof-verification scope decision gate.
- Reversal Trigger: NIP-41 merges with stable semantics and proof-verification scope is accepted for
  deterministic implementation.
- Principles Impacted: P01, P03, P05, P06.
- Scope Impacted: NIP-41 provisional planning, Phase C4 synthesis notes, Phase D contract gating.

## Tradeoff T-X-004: NIP-06 build-vs-buy before implementation

- Context: NIP-06 introduces BIP39/BIP32 correctness and security burden that can be built in-house or
  delegated to a vetted helper/wrapper boundary.
- Options:
  - O1: implement BIP39/BIP32 in-house for full control and uniform internal contracts.
  - O2: use vetted helper/wrapper path for primitives while keeping noztr protocol boundaries strict.
- Decision: decision-needed before NIP-06 implementation starts.
- Benefits: explicit upfront framing prevents implicit dependency-policy drift and hidden security debt.
- Costs: additional planning checkpoint before coding NIP-06.
- Risks: delayed H2 start if acceptance criteria stay ambiguous.
- Mitigations: define acceptance criteria and corpus requirements in pre-wave checkpoint artifacts.
- Reversal Trigger: evidence that one path cannot satisfy deterministic, typed-error, bounded
  contracts.
- Principles Impacted: P01, P03, P05, P06.
- Scope Impacted: H2 NIP-06 sequencing and dependency strategy checkpoint.

## Open Questions

- `OQ-X-001`: for NIP-41, should proof verification reuse NIP-03-style OTS verification directly or
  define a narrowed subset for deterministic bounded implementation.
- `OQ-X-002`: what objective parity evidence threshold should promote a currently deferred H3 NIP
  into the next H2 extension wave.
- `OQ-X-003`: what formal reversal criteria should be required before revisiting currently rejected
  NIPs (`07`, `08`, `47`, `55`).
- `OQ-X-004`: for NIP-06, should implementation be in-house BIP39/BIP32 logic or a vetted
  helper/wrapper strategy with strict boundary contracts.

## Principles Compliance

- Required sections are present: `Decisions`, `Feature Matrix`, `Implementation Roadmap`,
  `Tradeoffs`, `Open Questions`, `Principles Compliance`.
- `P01` preserved by keeping cryptographic/proof-sensitive scope (notably NIP-41) in explicit defer
  status until deterministic verification contracts are bounded.
- `P02` preserved by rejecting or deferring app-framework and policy-heavy surfaces (`47`, `55`,
  payment-heavy items) from near-term extension contracts.
- `P03` preserved by explicit classification and staged H2/H3 sequencing instead of ad-hoc feature
  inclusion.
- `P04` preserved by keeping routing/policy-impacting items explicit in roadmap waves and not hidden
  in core defaults.
- `P05` preserved by requiring deterministic rationale and bounded validation posture in every
  expansion-candidate row.
- `P06` preserved by sequencing only bounded, contractable extension semantics in H2 and deferring
  higher-ambiguity areas to H3.
