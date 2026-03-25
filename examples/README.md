# noztr-core Examples

Downstream consumption examples for `noztr-sdk`, other SDKs, and application authors.

These examples are intentionally technical and direct. They are not only "happy path" demos.
Where a surface is trust-boundary-heavy, the example set should also grow hostile or invalid
fixtures so SDK and app authors can see what `noztr-core` rejects and why.

## Related Public Docs

Use these docs when you need routing or contract context before opening a file:

- [getting-started.md](../docs/getting-started.md)
- [technical-guides.md](../docs/guides/technical-guides.md)
- [core-api-contracts.md](../docs/reference/core-api-contracts.md)
- [contract-map.md](../docs/reference/contract-map.md)
- [api-reference.md](../docs/reference/api-reference.md)
- [errors-and-ownership.md](../docs/errors-and-ownership.md)

If you know the job but not the symbol, start with
[technical-guides.md](../docs/guides/technical-guides.md) or
[contract-map.md](../docs/reference/contract-map.md).
If you already know the symbol family, use
[api-reference.md](../docs/reference/api-reference.md).

## Start Here

- `consumer_smoke.zig`
  - minimal package/import check
- `strict_core_recipe.zig`
  - best first entry point for strict event, message, transcript, and wrapper flows
- `remote_signing_recipe.zig`
  - best first entry point for `noztr-sdk` signer/session work
- `wallet_recipe.zig`
  - best first entry point for deterministic wallet flows
- `discovery_recipe.zig`
  - best first entry point for identity lookup and bunker discovery

## Choose By Job

Use [core-api-contracts.md](../docs/reference/core-api-contracts.md) and
[contract-map.md](../docs/reference/contract-map.md) as the canonical job-to-route map.

This README should help you pick the right example shape quickly:

- recipe:
  - higher-signal grouped path for a real downstream job
- direct example:
  - module-specific reference and happy-path usage
- adversarial example:
  - hostile or invalid imported-input coverage for the same surface

| Job | Start file | Hostile / failure fixture |
| --- | --- | --- |
| Identity lookup and bunker discovery | `discovery_recipe.zig` | `nip05_adversarial_example.zig` |
| Remote-signing requests, URIs, and typed responses | `remote_signing_recipe.zig` | `remote_signing_adversarial_example.zig` |
| Legacy kind-4 DM crypto and event-shape validation | `nip04_dm_recipe.zig` | `nip04_adversarial_example.zig` |
| One-recipient gift-wrap outbound build and unwrap | `nip17_wrap_recipe.zig` | `nip59_adversarial_example.zig` |
| Wallet Connect envelope and JSON helpers | `nip47_example.zig` | `wallet_connect_adversarial_example.zig` |
| Relay-admin JSON-RPC helpers | `relay_admin_recipe.zig` | `relay_admin_adversarial_example.zig` |
| HTTP auth event and header helpers | `nip98_example.zig` | `http_auth_adversarial_example.zig` |
| Moderated-community definitions, post linkage, and approval contracts | `nip72_example.zig` | `nip72_adversarial_example.zig` |
| Private draft and relay-list storage | `nip37_example.zig` | `nip37_adversarial_example.zig` |
| Group replay and poll tally reduction | `nip29_reducer_recipe.zig` / `nip88_example.zig` | `nip29_adversarial_example.zig` / `polls_adversarial_example.zig` |

## Predictable Example Naming

Most routes follow one obvious example pattern:

- direct route example:
  - `nipXX_example.zig`
- hostile or invalid-input companion:
  - `*_adversarial_example.zig`
- grouped downstream job:
  - `*_recipe.zig`

If you need the full module surface, use
[api-reference.md](../docs/reference/api-reference.md).
If you need the right route for a job, use
[core-api-contracts.md](../docs/reference/core-api-contracts.md) or
[contract-map.md](../docs/reference/contract-map.md).

## Scenario Recipes

The recipe files are slightly higher-level, but still stay inside `noztr` boundaries.

- `discovery_recipe.zig`
  - NIP-05 plus NIP-46 discovery parsing
- `wallet_recipe.zig`
  - NIP-06 plus Nostr-focused BIP-85 helpers
- `strict_core_recipe.zig`
  - canonical event lifecycle, strict message grammar, transcript flow, and checked wrappers
- `identity_proof_recipe.zig`
  - NIP-39 proof URL and expected-text helpers
- `remote_signing_recipe.zig`
  - NIP-46 request, URI, and template composition
- `nip03_verification_recipe.zig`
  - NIP-03 extraction plus bounded local-proof verification
- `nip04_dm_recipe.zig`
  - `NIP-04` local encrypt/decrypt plus strict kind-4 event parse/verify flow
- `nip17_wrap_recipe.zig`
  - NIP-17 rumor construction, deterministic one-recipient seal/wrap transcript building, and unwrap
- `nip29_reducer_recipe.zig`
  - NIP-29 pure reducer replay across metadata, snapshot, and moderation events
- `private_lists_recipe.zig`
  - NIP-51 private-list JSON boundary
- `relay_admin_recipe.zig`
  - NIP-86 relay-management request and response helpers

## Adversarial Examples

These are the first files to open when you need the failure contract for a boundary-heavy surface.

- `remote_signing_adversarial_example.zig`
  - invalid `nostrconnect_url` template rendering
- `nip42_adversarial_example.zig`
  - mismatched relay challenge stays on typed `NIP-42` auth failures
- `nip03_adversarial_example.zig`
  - malformed OpenTimestamps proof payload stays on typed `InvalidBase64`
- `nip04_adversarial_example.zig`
  - malformed legacy payloads and duplicate recipient tags stay on typed `NIP-04` failures
- `nip17_adversarial_example.zig`
  - overlong recipient and relay builder input stays on typed `NIP-17` failures
- `nip37_adversarial_example.zig`
  - overlong private relay builder input stays on typed `InvalidPrivateRelayUrl`
- `nip59_adversarial_example.zig`
  - sender/rumor mismatch on outbound wrap construction stays on typed `InvalidRumorEvent`
- `nip05_adversarial_example.zig`
  - malformed matched pubkeys and relay maps stay on typed `NIP-05` failures
- `relay_admin_adversarial_example.zig`
  - invalid control text on NIP-86 serializer paths
- `nip72_adversarial_example.zig`
  - top-level lowercase community mismatch stays on typed `TopLevelCommunityMismatch`
- `private_lists_adversarial_example.zig`
  - deprecated NIP-04 private content and non-websocket private relays
- `identity_proof_adversarial_example.zig`
  - overlong NIP-39 identity inputs on typed builder paths
- `media_metadata_adversarial_example.zig`
  - missing `imeta` metadata and non-canonical file MIME values
- `listings_adversarial_example.zig`
  - invalid NIP-99 listing identifiers on both builder and extractor paths
- `code_snippet_adversarial_example.zig`
  - malformed NIP-C0 repository references rejected on both builder and extractor paths
- `chess_pgn_adversarial_example.zig`
  - malformed NIP-64 PGN structure rejected on both validator and metadata-builder paths
- `polls_adversarial_example.zig`
  - latest malformed same-poll responses suppress older votes and invalid response tags stay typed
- `private_key_encryption_adversarial_example.zig`
  - wrong passwords stay on `InvalidCiphertext` and invalid scrypt parameters stay typed
- `wallet_connect_adversarial_example.zig`
  - malformed NWC request bodies and mismatched notification shapes stay on typed failures
- `http_auth_adversarial_example.zig`
  - malformed `Authorization` values and noncanonical payload hashes stay on typed failures
- `nip28_adversarial_example.zig`
  - overlong channel reference builder input stays on typed `InvalidChannelTag`
- `nip61_adversarial_example.zig`
  - target kind without a target event stays on typed `TargetKindWithoutEvent`
- `nip89_adversarial_example.zig`
  - malformed client handler coordinates stay on typed `InvalidClientTag`
- `blossom_adversarial_example.zig`
  - malformed server URLs and query-bearing blob URLs stay on typed `NIP-B7` failures
- `nip29_adversarial_example.zig`
  - mixed-group moderation replay rejected by the pure reducer

## Boundary

These examples stay at the `noztr` layer:
- deterministic parsing
- deterministic building
- bounded validation

They intentionally do not show:
- relay pools
- HTTP fetch
- storage/state sync
- UI or session orchestration

That work belongs in `noztr-sdk` or above it.

## Example Quality Rule

For boundary-heavy surfaces, examples should not stop at valid flows. The preferred set is:
- one direct valid reference example
- one invalid or adversarial example fixture where misuse is plausible
- recipe coverage only when the surface materially affects SDK-facing handoff work

When the example policy gets stricter, recently added SDK-facing examples must be backfilled to the
new standard before the repo claims the stronger example baseline.
