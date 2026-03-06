# Zig Ecosystem Crypto Survey and Fit Assessment for `noztr`

Date: 2026-03-05

## Scope

- Document current crypto implementation options relevant to `noztr` v1 and near-term extensions.
- Focus areas: secp256k1 signatures, BIP340 Schnorr, bech32/TLV, and NIP-44/NIP-59 dependent primitives.
- Inputs are ecosystem survey findings plus Zig stdlib (`0.15.2`) capability review.
- This note is an assessment artifact only; it does not change implementation policy or dependency policy.

## Sources

- Awesome Zig and adjacent ecosystem review (candidate repo discovery + maintenance signal pass).
- Zig stdlib capability check at version `0.15.2` for required cryptographic primitives.
- Existing `noztr` planning constraints in `docs/plans/nostr-principles.md` and `docs/plans/decision-log.md`.
- Additional NIP horizon sequencing in `docs/plans/v1-additional-nips-roadmap.md`.

## Zig stdlib capability matrix for noztr needs

| Capability needed by `noztr` | Zig stdlib `0.15.2` status | Fit assessment |
| --- | --- | --- |
| SHA-256 / SHA-512 | Available | Sufficient for v1 hashing needs. |
| HMAC | Available | Sufficient for NIP-44 composition components. |
| HKDF | Available | Sufficient for NIP-44 key derivation path. |
| ChaCha20 | Available | Sufficient as stream cipher primitive for NIP-44 flow. |
| secp256k1 curve ops / ECDSA | Available | Useful secp256k1 primitive support; ECDSA availability does not satisfy NIP-01 Schnorr/BIP340 signature requirements. |
| BIP340 Schnorr (secp256k1) | No obvious dedicated module | Primary gap; highest crypto implementation risk if stdlib-only. |
| bech32 codec | Not present | Non-crypto but critical codec gap for NIP-19 strict decoding/encoding. |

## Ecosystem candidates (ranked shortlist with recommendation)

| Rank | Candidate | Coverage fit | Vetting signal | Recommendation |
| --- | --- | --- | --- | --- |
| 1 | `bitcoin-core/secp256k1` (direct C library) | Strong for secp256k1 + BIP340 Schnorr | High: long-lived, widely audited, production use | Best technical fallback if policy allows external deps. |
| 2 | Zig wrapper over `bitcoin-core/secp256k1` | Same crypto coverage with Zig-facing API | Medium-High: depends on wrapper quality + upstream C assurance | Acceptable only with strict wrapper audit + bounded API boundary. |
| 3 | Pure-Zig secp256k1/Schnorr repos (surveyed set) | Partial to mixed; quality varies | Low-Medium: less audit depth, smaller usage surface | Not recommended as default trust anchor for `noztr` crypto core. |
| 4 | Zig bech32 standalone repos | Can cover NIP-19 codec gap | Low-Medium: mixed test depth and maintenance cadence | Consider as reference input, not as default dependency. |

## Trust and vetting assessment

- Highest confidence path for Schnorr correctness remains `bitcoin-core/secp256k1` due to maturity and ecosystem exposure.
- Pure-Zig crypto candidates are useful for study and differential testing, but most are not equivalently vetted.
- For `noztr`, correctness risk is concentrated in composition and strictness boundaries, not only primitive availability.
- Highest-risk implementation items:
  - BIP340 Schnorr correctness and edge-case handling.
  - NIP-44 composition correctness (ordering, MAC verification, padding handling).
  - NIP-59 unwrap staged verification and sender/structure checks.
  - NIP-19 bech32 + TLV strict parser behavior.
  - BIP32 serialization/fingerprint family if scope expands.

## Additional NIPs roadmap implications for crypto/dependency planning

- H2 expansion-candidate `06` (BIP39/BIP32 key derivation) is the primary roadmap item likely to increase crypto and wallet-helper requirements.
- H2 `46` and `51` remain important for extension sequencing but are mostly protocol/message boundary work, not low-level primitive drivers.
- H3 deferred payment/ecash lane (`57`, `60`, `61`) and provisional NIP-41 tracking do not change current v1 crypto dependency posture.

## Wrapper Placement Strategy

- Recommendation: start with an in-repo thin wrapper module for any vetted external crypto backend
  integration path.
- Rationale: keeps boundary ownership, test harnesses, typed errors, and deterministic contracts close
  to `noztr` implementation gates.
- Extraction trigger: move wrapper to a dedicated repo only when there are multiple external consumers
  and sustained stable-API pressure.
- Policy note: this placement strategy does not change current dependency policy by itself.

## Why noztr remains differentiated

- `noztr` value is protocol-contract rigor, not just primitive implementation source.
- Differentiators remain:
  - strict deterministic protocol contracts at trust boundaries.
  - bounded memory/work behavior and typed error surfaces.
  - check-order rigor with mandatory invalid-corpus coverage.
  - behavior-parity targeting without API-shape coupling.
- Result: even with a vetted crypto backend for primitives, `noztr` still owns and guarantees Nostr
  protocol boundary correctness and deterministic integration semantics.

## Additional NIPs dependency forecast (external libs)

### H2 candidates

| NIP | External dependency level | Likely external capability/library | Reason |
| --- | --- | --- | --- |
| 06 | recommended | BIP39 mnemonic and BIP32/HD-key helper implementation (potentially with secp256k1 backend) | Wallet derivation correctness and corpus breadth are expensive to re-derive from scratch. |
| 10 | none | N/A | Thread/reply semantics are deterministic event/tag validation. |
| 18 | none | N/A | Repost semantics stay within bounded event-shape checks. |
| 22 | none | N/A | Comment semantics are protocol validation work, not new primitives. |
| 23 | none | N/A | Long-form metadata handling is parser/validator scope. |
| 25 | none | N/A | Reactions are simple kind/tag rules. |
| 27 | optional | Robust text-reference tokenizer/link extractor | Better cross-client reference parsing may benefit from proven tokenizer behavior. |
| 36 | none | N/A | Sensitive-content signaling is bounded tag validation. |
| 46 | none | N/A | Remote-signing flow is message/state boundary work over existing crypto primitives. |
| 48 | none | N/A | Proxy tags are metadata conventions with strict validation. |
| 51 | none | N/A | List semantics are deterministic event encoding/validation. |
| 56 | none | N/A | Reporting is event/tag policy validation. |
| 58 | none | N/A | Badge semantics remain metadata-level processing. |
| 98 | none | N/A | HTTP auth event flow can reuse existing signature/challenge checks. |
| 99 | none | N/A | Classified listing semantics are structured metadata validation. |

### H3 deferred/provisional

| NIP | External dependency level | Likely external capability/library | Reason |
| --- | --- | --- | --- |
| 03 | recommended | OpenTimestamps proof verification implementation | OTS proof parsing/verification interoperability is easier with mature proof logic. |
| 14 | none | N/A | Subject tags are straightforward event/tag checks. |
| 24 | none | N/A | Extra metadata conventions do not require new crypto primitives. |
| 26 | none | N/A | Delegation semantics are primarily trust-boundary policy checks. |
| 30 | none | N/A | Emoji metadata is non-cryptographic convention handling. |
| 31 | none | N/A | `alt` fallback handling is parser behavior, not primitive expansion. |
| 32 | none | N/A | Labeling semantics are policy/validation scope. |
| 38 | none | N/A | User status events are bounded metadata behavior. |
| 39 | recommended | External identity claim verification helpers (DID/domain attestation toolchains) | Identity proof ecosystems are heterogeneous and commonly rely on external verifiers. |
| 41 (provisional) | recommended | OTS-style proof verification helper set | Provisional account-switch proofs likely reuse timestamp/proof validation complexity. |
| 52 | none | N/A | Calendar semantics are domain-model extensions, not primitive requirements. |
| 53 | none | N/A | Live activity lifecycles are state/validation work. |
| 57 | effectively required | Lightning invoice/zap verification stack (BOLT11/LNURL ecosystem libs) | Payment request/receipt verification usually depends on established Lightning tooling. |
| 60 | effectively required | Cashu/ecash token protocol implementation | Ecash mint/token workflows are specialized and impractical to duplicate safely. |
| 61 | effectively required | Nutzap/ecash integration stack (built atop Cashu/payment primitives) | Nutzap depends on mature ecash/payment protocol handling. |

## Recommendation for noztr (now / later)

- Now (current policy): keep stdlib-only path and treat Schnorr + bech32 as explicit high-risk implementation work items requiring stronger vectors and differential checks.
- Now (execution posture): prioritize strict staged validation and invalid corpus depth for `nip44`, `nip59_wrap`, and `nip19_bech32` contracts.
- Immediate dependency-decision scope remains v1/H1; H2/H3 items from `docs/plans/v1-additional-nips-roadmap.md` are tracked as future policy checkpoints.
- Later (policy-gated option): if implementation risk or parity evidence is unacceptable, evaluate a narrow external exception for Schnorr via `bitcoin-core/secp256k1` (or audited Zig wrapper), behind a formal policy decision.

## Open policy decision (if any)

- `OPD-CRYPTO-001` Topic: allow a narrowly-scoped external dependency exception for BIP340 Schnorr.
  - Current default: no; project policy remains stdlib-only / zero external dependencies.
  - Scope note: this OPD remains anchored to v1/H1 delivery; H2/H3 roadmap items are checkpoint triggers, not immediate dependency drivers.
  - Trigger to revisit: repeated conformance failures, unacceptable security uncertainty, or sustained parity gaps under stdlib-only implementation.
  - Decision authority: must be recorded through `docs/plans/decision-log.md` change-control process.

No dependency decision is changed by this note, including the roadmap addendum integration.
