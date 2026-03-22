---
title: Migrating From 0.1.0-rc.1
doc_type: release_guide
status: active
owner: noztr
read_when:
  - updating_from_0_1_0_rc_1
  - adapting_to_recent_public_api_breaks
canonical: true
---

# Migrating From `0.1.0-rc.1`

This guide covers the first intentional public API cleanup after `v0.1.0-rc.1`.

The current line is still pre-`1.0.0`, so deliberate public-surface cleanup can still happen. When
it does, the change should be explicit and downstream callers should get one clear migration path.

## What Changed

Two public-surface normalization changes landed after `v0.1.0-rc.1`:

- temporary compatibility aliases introduced during the API-naming normalization pass were removed
- the remaining older public NIP-module error type names were normalized to the same module-shaped
  naming pattern used across the rest of the library

These are breaking changes for downstream code that referenced the removed alias symbols or the old
error type names.

## Renamed Symbols

Use these canonical names now:

- `noztr.nip21_uri.nip21_parse` -> `noztr.nip21_uri.uri_parse`
- `noztr.nip21_uri.nip21_is_valid` -> `noztr.nip21_uri.uri_is_valid`
- `noztr.nip47_wallet_connect.connection_uri_format` ->
  `noztr.nip47_wallet_connect.connection_uri_serialize`
- `noztr.nip36_content_warning.build_content_warning_tag` ->
  `noztr.nip36_content_warning.content_warning_build_tag`
- `noztr.nip36_content_warning.build_content_warning_namespace_tag` ->
  `noztr.nip36_content_warning.content_warning_build_namespace_tag`
- `noztr.nip36_content_warning.build_content_warning_label_tag` ->
  `noztr.nip36_content_warning.content_warning_build_label_tag`
- `noztr.nip24_extra_metadata.build_reference_tag` ->
  `noztr.nip24_extra_metadata.common_tags_build_reference_tag`
- `noztr.nip24_extra_metadata.build_title_tag` ->
  `noztr.nip24_extra_metadata.common_tags_build_title_tag`
- `noztr.nip24_extra_metadata.build_hashtag_tag` ->
  `noztr.nip24_extra_metadata.common_tags_build_hashtag_tag`
- `noztr.nip56_reporting.build_pubkey_report_tag` ->
  `noztr.nip56_reporting.report_build_pubkey_tag`
- `noztr.nip56_reporting.build_event_report_tag` ->
  `noztr.nip56_reporting.report_build_event_tag`
- `noztr.nip56_reporting.build_blob_report_tag` ->
  `noztr.nip56_reporting.report_build_blob_tag`
- `noztr.nip56_reporting.build_server_tag` ->
  `noztr.nip56_reporting.report_build_server_tag`
- `noztr.nip57_zaps.build_pubkey_tag` ->
  `noztr.nip57_zaps.zap_build_pubkey_tag`
- `noztr.nip57_zaps.build_event_tag` ->
  `noztr.nip57_zaps.zap_build_event_tag`
- `noztr.nip57_zaps.build_coordinate_tag` ->
  `noztr.nip57_zaps.zap_build_coordinate_tag`
- `noztr.nip57_zaps.build_kind_tag` ->
  `noztr.nip57_zaps.zap_build_kind_tag`

## Renamed Error Types

Use these public error type names now:

- `noztr.nip02_contacts.ContactsError` -> `noztr.nip02_contacts.Nip02Error`
- `noztr.nip03_opentimestamps.OpenTimestampsError` -> `noztr.nip03_opentimestamps.Nip03Error`
- `noztr.nip09_delete.DeleteError` -> `noztr.nip09_delete.Nip09Error`
- `noztr.nip10_threads.ThreadError` -> `noztr.nip10_threads.Nip10Error`
- `noztr.nip18_reposts.RepostError` -> `noztr.nip18_reposts.Nip18Error`
- `noztr.nip22_comments.CommentError` -> `noztr.nip22_comments.Nip22Error`
- `noztr.nip23_long_form.LongFormError` -> `noztr.nip23_long_form.Nip23Error`
- `noztr.nip25_reactions.ReactionError` -> `noztr.nip25_reactions.Nip25Error`
- `noztr.nip27_references.ReferencesError` -> `noztr.nip27_references.Nip27Error`
- `noztr.nip40_expire.ExpirationError` -> `noztr.nip40_expire.Nip40Error`
- `noztr.nip42_auth.AuthError` -> `noztr.nip42_auth.Nip42Error`
- `noztr.nip45_count.CountError` -> `noztr.nip45_count.Nip45Error`
- `noztr.nip47_wallet_connect.NwcError` -> `noztr.nip47_wallet_connect.Nip47Error`
- `noztr.nip50_search.SearchError` -> `noztr.nip50_search.Nip50Error`
- `noztr.nip51_lists.ListError` -> `noztr.nip51_lists.Nip51Error`
- `noztr.nip51_lists.PrivateListError` -> `noztr.nip51_lists.Nip51PrivateListError`
- `noztr.nip59_wrap.WrapError` -> `noztr.nip59_wrap.Nip59Error`
- `noztr.nip59_wrap.WrapBuildError` -> `noztr.nip59_wrap.Nip59BuildError`
- `noztr.nip65_relays.RelaysError` -> `noztr.nip65_relays.Nip65Error`
- `noztr.nip70_protected.ProtectedError` -> `noztr.nip70_protected.Nip70Error`
- `noztr.nip77_negentropy.NegentropyError` -> `noztr.nip77_negentropy.Nip77Error`
- `noztr.nipb0_web_bookmarking.WebBookmarkError` -> `noztr.nipb0_web_bookmarking.NipB0Error`
- `noztr.nipc0_code_snippets.CodeSnippetError` -> `noztr.nipc0_code_snippets.NipC0Error`

## Why

The goal was to make the public surface more coherent:

- one obvious naming shape per module
- fewer bare `build_*` names in otherwise domain-prefixed APIs
- fewer redundant module-number prefixes where the module namespace already carries that meaning
- more consistent parse/build/serialize verb shape across similar modules

## Downstream Guidance

If your project depends on `noztr-core`:

1. update imports, call sites, and any explicit error type references to the canonical names above
2. rerun your normal build and example/test lanes
3. if you publish wrappers around `noztr`, consider re-exporting only the canonical names

## Scope

These changes only normalize public symbol and error type names. They do not change:

- wire formats
- ownership model
- typed error intent
- protocol/kernel versus SDK boundary
