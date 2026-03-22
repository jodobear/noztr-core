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

Temporary compatibility aliases introduced during the API-naming normalization pass were removed.
The canonical names remain.

This is a breaking change for code that adopted the temporary alias symbols.

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

## Why

The goal was to make the public surface more coherent:

- one obvious naming shape per module
- fewer bare `build_*` names in otherwise domain-prefixed APIs
- fewer redundant module-number prefixes where the module namespace already carries that meaning
- more consistent parse/build/serialize verb shape across similar modules

## Downstream Guidance

If your project depends on `noztr-core`:

1. update imports and call sites to the canonical names above
2. rerun your normal build and example/test lanes
3. if you publish wrappers around `noztr`, consider re-exporting only the canonical names

## Scope

This change only removes temporary public naming aliases. It does not change:

- wire formats
- ownership model
- typed error intent
- protocol/kernel versus SDK boundary

