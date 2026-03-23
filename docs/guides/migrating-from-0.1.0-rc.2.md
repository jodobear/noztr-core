---
title: Migrating From 0.1.0-rc.2
doc_type: release_guide
status: active
owner: noztr
read_when:
  - updating_from_0_1_0_rc_2
  - adapting_to_recent_public_api_breaks
canonical: true
---

# Migrating From `0.1.0-rc.2`

This guide covers the first route-internal naming cleanup after `v0.1.0-rc.2`.

The current line is still pre-`1.0.0`, so clarity-driven public cleanup can still happen. When it
does, the change should stay narrow and downstream callers should get one exact migration map.

## What Changed

The first surface-noise remediation lane shortens public type names inside canonical grouped routes.

The grouped route already carries the main context, so these names now prefer shorter role-based
symbols instead of restating the full route in every type.

This is a breaking change for downstream code that referenced the old public type names directly.

## Renamed Symbols

Use these public names now:

- `noztr.nip04.Nip04IvProvider` -> `noztr.nip04.IvProvider`
- `noztr.nip04.Nip04Payload` -> `noztr.nip04.Payload`
- `noztr.nip04.Nip04ReplyRef` -> `noztr.nip04.ReplyRef`
- `noztr.nip04.Nip04MessageInfo` -> `noztr.nip04.MessageInfo`
- `noztr.nip21_uri.Nip21Reference` -> `noztr.nip21_uri.Reference`
- `noztr.nip44.Nip44NonceProvider` -> `noztr.nip44.NonceProvider`
- `noztr.nip44.Nip44DecodedPayload` -> `noztr.nip44.DecodedPayload`
- `noztr.nip46_remote_signing.RemoteSigningMethod` -> `noztr.nip46_remote_signing.Method`
- `noztr.nip46_remote_signing.PermissionScope` -> `noztr.nip46_remote_signing.Scope`
- `noztr.nip46_remote_signing.ConnectRequest` -> `noztr.nip46_remote_signing.ConnectParams`
- `noztr.nip46_remote_signing.PubkeyTextRequest` ->
  `noztr.nip46_remote_signing.PubkeyTextParams`
- `noztr.nip46_remote_signing.BunkerUri` -> `noztr.nip46_remote_signing.Bunker`
- `noztr.nip46_remote_signing.ClientUri` -> `noztr.nip46_remote_signing.Client`
- `noztr.nip46_remote_signing.ConnectionUri` -> `noztr.nip46_remote_signing.Uri`
- `noztr.nip46_remote_signing.DiscoveryInfo` -> `noztr.nip46_remote_signing.Discovery`

## Why

The goal is to reduce public-surface repetition and make the grouped routes easier to scan:

- the module path already carries the NIP and route context
- shorter role-based names are easier for humans to read in code
- shorter role-based names are easier for LLMs to retrieve and reuse accurately
- this keeps the obvious safe path more obvious without changing wire behavior

## Downstream Guidance

If your project depends on `noztr-core`:

1. update any explicit type references to the names above
2. update wrappers, re-exports, and examples that teach the old names
3. rerun your normal build/test gates
4. refresh any generated symbol indexes or local LLM context packs that still reference the old
   names

## Scope

These changes rename public types only. They do not change:

- wire formats
- ownership model
- typed error intent
- protocol/kernel versus SDK boundary
