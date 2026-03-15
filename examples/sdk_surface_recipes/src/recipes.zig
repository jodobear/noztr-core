const std = @import("std");
const noztr = @import("noztr");

test "nip05 and nip46 discovery flow stays straightforward" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const address = try noztr.nip05_identity.address_parse(
        "alice@example.com",
        arena.allocator(),
    );
    var lookup_url_buffer: [128]u8 = undefined;
    const lookup_url = try noztr.nip05_identity.address_compose_well_known_url(
        lookup_url_buffer[0..],
        &address,
    );

    const document =
        "{\"names\":{\"_\":\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\"," ++
        "\"alice\":\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\"}," ++
        "\"relays\":{\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\":" ++
        "[\"wss://relay.one\"]},\"nip46\":{\"relays\":[\"wss://relay.one\"]," ++
        "\"nostrconnect_url\":\"https://bunker.example/<nostrconnect>\"}}";
    const profile = try noztr.nip05_identity.profile_parse_json(&address, document, arena.allocator());
    const discovery = try noztr.nip46_remote_signing.discovery_parse_well_known(
        document,
        arena.allocator(),
    );

    try std.testing.expectEqualStrings(
        "https://example.com/.well-known/nostr.json?name=alice",
        lookup_url,
    );
    try std.testing.expectEqual(@as(usize, 1), profile.relays.len);
    try std.testing.expectEqual(@as(usize, 1), discovery.relays.len);
    try std.testing.expectEqualStrings("wss://relay.one", discovery.relays[0]);
}

test "nip06 and bip85 wallet flow uses deterministic helpers" {
    const mnemonic =
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage";
    var secret_output: [32]u8 = undefined;
    var child_mnemonic_output: [noztr.limits.bip85_mnemonic_bytes_max]u8 = undefined;

    const secret_key = try noztr.nip06_mnemonic.derive_nostr_secret_key(
        secret_output[0..],
        mnemonic,
        null,
        0,
    );
    const child_mnemonic = try noztr.bip85_derivation.derive_bip39_mnemonic(
        child_mnemonic_output[0..],
        mnemonic,
        null,
        .words_12,
        0,
    );

    try std.testing.expectEqual(@as(usize, 32), secret_key.len);
    try std.testing.expectEqualStrings(
        "girl mad pet galaxy egg matter matrix prison refuse sense ordinary nose",
        child_mnemonic,
    );
}

test "nip39 proof helper flow stays pure" {
    const claim = noztr.nip39_external_identities.IdentityClaim{
        .provider = .github,
        .identity = "semisol",
        .proof = "9721ce4ee4fceb91c9711ca2a6c9a5ab",
    };
    const pubkey = [_]u8{0x22} ** 32;
    var url_buffer: [256]u8 = undefined;
    var text_buffer: [256]u8 = undefined;

    const url = try noztr.nip39_external_identities.identity_claim_build_proof_url(
        url_buffer[0..],
        &claim,
    );
    const text = try noztr.nip39_external_identities.identity_claim_build_expected_text(
        text_buffer[0..],
        &claim,
        &pubkey,
    );

    try std.testing.expectEqualStrings(
        "https://gist.github.com/semisol/9721ce4ee4fceb91c9711ca2a6c9a5ab",
        url,
    );
    try std.testing.expect(std.mem.indexOf(u8, text, "npub1") != null);
}

test "nip46 request and discovery rendering compose cleanly" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    var request_output: noztr.nip46_remote_signing.BuiltRequest = .{};
    const request = try noztr.nip46_remote_signing.request_build_connect(
        &request_output,
        "sdk-connect",
        &.{
            .remote_signer_pubkey = [_]u8{0x01} ** 32,
            .secret = "secret",
            .requested_permissions = &.{
                .{ .method = .ping },
                .{ .method = .sign_event, .scope = .{ .event_kind = 1 } },
            },
        },
        arena.allocator(),
    );
    var uri_output: [noztr.limits.nip46_uri_bytes_max]u8 = undefined;
    const connection_uri = try noztr.nip46_remote_signing.uri_serialize(
        uri_output[0..],
        .{ .client = .{
            .client_pubkey = [_]u8{0x02} ** 32,
            .relays = &.{"wss://relay.one"},
            .secret = "secret",
            .permissions = &.{.{ .method = .ping }},
            .name = "SDK Client",
        } },
    );
    var rendered_output: [noztr.limits.nip46_uri_bytes_max]u8 = undefined;
    const rendered = try noztr.nip46_remote_signing.discovery_render_nostrconnect_url(
        rendered_output[0..],
        "https://bunker.example/connect/<nostrconnect>",
        connection_uri,
        arena.allocator(),
    );

    try std.testing.expectEqual(.connect, request.method);
    try std.testing.expect(std.mem.indexOf(u8, rendered, "nostrconnect://") != null);
}

test "nip51 private list json helpers roundtrip" {
    const pubkey_tag = [_][]const u8{
        "p",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    };
    const word_tag = [_][]const u8{ "word", "spam phrase" };
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = pubkey_tag[0..] },
        .{ .items = word_tag[0..] },
    };
    var json_output: [256]u8 = undefined;
    const json = try noztr.nip51_lists.list_private_serialize_json(json_output[0..], tags[0..]);
    var items: [2]noztr.nip51_lists.ListItem = undefined;
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const parsed = try noztr.nip51_lists.list_private_extract_json(
        10000,
        json,
        items[0..],
        arena.allocator(),
    );

    try std.testing.expectEqual(.mute_list, parsed.kind);
    try std.testing.expect(items[0] == .pubkey);
    try std.testing.expect(items[1] == .word);
}

test "nip86 relay management request and response helpers roundtrip" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const request_json =
        "{\"method\":\"banpubkey\",\"params\":[\"0123456789abcdef0123456789abcdef" ++
        "0123456789abcdef0123456789abcdef\",\"spam\"]}";
    const request = try noztr.nip86_relay_management.request_parse_json(
        request_json,
        arena.allocator(),
    );
    var request_output: [256]u8 = undefined;
    const encoded_request = try noztr.nip86_relay_management.request_serialize_json(
        request_output[0..],
        request,
    );

    var pubkeys: [1]noztr.nip86_relay_management.PubkeyReason = undefined;
    var methods: [1][]const u8 = undefined;
    var events: [1]noztr.nip86_relay_management.EventIdReason = undefined;
    var kinds: [1]u32 = undefined;
    var ips: [1]noztr.nip86_relay_management.IpReason = undefined;
    const response = try noztr.nip86_relay_management.response_parse_json(
        "{\"result\":true,\"error\":null}",
        .banpubkey,
        methods[0..],
        pubkeys[0..],
        events[0..],
        kinds[0..],
        ips[0..],
        arena.allocator(),
    );

    try std.testing.expect(request == .banpubkey);
    try std.testing.expectEqualStrings(request_json, encoded_request);
    try std.testing.expect(response.result == .ack);
}
