# Crypto Boundary Evaluation

Current review of `noztr`'s crypto-adjacent Zig wrapper posture, grounded in the existing
`secp256k1` and `libwally` backend boundaries plus the newly accepted NFKD/BIP-85 work.

## Question

Should the current crypto wrapper stay inside `noztr`, or should it become a standalone lower-level
library usable across Bitcoin / Lightning / Cashu / Nostr projects?

## Current State

- `src/crypto/secp256k1_backend.zig` is a narrow protocol-kernel backend wrapper.
- `src/nip06_mnemonic.zig` and `src/bip85_derivation.zig` sit on top of `libwally` for BIP39,
  PBKDF2, BIP32, and bounded BIP-85 derivation.
- `src/unicode_nfkd.zig` is an internal Unicode normalization helper used to make the BIP39/NIP-06
  boundary fully NFKD-compatible without adding a runtime dependency.

This is enough for `noztr`, but it is not yet a generally reusable Zig Bitcoin primitive library.

## Recommendation

Keep the current crypto wrapper in `noztr` for now.

Do not extract the current boundary as-is into a standalone project yet.

Create a future standalone-library track only after separate ground-up research confirms:
- the target consumers really extend beyond `noztr` / `nzdk`
- the desired scope is stable
- the dependency and backend posture is acceptable outside the protocol kernel

## Why Not Extract As-Is

- The current wrapper is shaped around `noztr`'s protocol needs, not a broad Bitcoin primitive API.
- The `libwally` boundary is useful, but the current exported helpers mix protocol-specific
  contracts with lower-level derivation concerns.
- `src/unicode_nfkd.zig` exists because BIP39/NIP-06 requires NFKD normalization, but Unicode
  normalization is not itself a secp256k1 primitive.
- A rushed extraction would likely produce a library that is too narrow for the Bitcoin ecosystem
  and too broad for `noztr`.

## What A Standalone Library Would Own

If a standalone lower-level library is created later, the likely kernel should be:

- secp256k1 key validation, serialization, x-only handling, Schnorr sign/verify, ECDSA, ECDH,
  tweak/add/mul, and tagged-hash helpers where they materially improve reuse
- BIP32 child derivation and key material handling
- fixed-capacity typed error surfaces and zeroization boundaries
- backend isolation and pinning policy

## What It Should Not Own

- Nostr event / NIP logic
- wallet UX or account-management flow
- relay / client orchestration
- NIP-44, gift wrap, or protocol-shaped message logic
- general Unicode text processing beyond clearly justified mnemonic/seed boundaries

## Suggested Research Scope

If this standalone-library track is opened later, start with a dedicated study covering:

1. consumer map
   - `noztr`
   - `nzdk`
   - Bitcoin wallet / signer libraries
   - Lightning or Cashu integrations
2. primitive surface
   - secp256k1
   - BIP32
   - BIP39 / NFKD adjacency
   - hash/tagged-hash helpers
3. backend policy
   - keep `libsecp256k1` / `libwally` wrappers
   - replace one or both
   - split secp-only vs wallet-derivation layers
4. Zig package and release model
   - standalone repo
   - dependency posture
   - versioning and test corpus

## Current Call

- `noztr` remains the right home for the current protocol-kernel crypto boundary.
- A future standalone lower-level Zig crypto / Bitcoin primitive library is plausible and probably
  valuable.
- It should begin as a separate research track, not as an immediate code extraction.
