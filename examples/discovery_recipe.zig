const std = @import("std");
const noztr = @import("noztr");

test "recipe: identity lookup and bunker discovery stay obvious" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var rendered_output: [noztr.limits.nip46_uri_bytes_max]u8 = undefined;
    var uri_output: [noztr.limits.nip46_uri_bytes_max]u8 = undefined;

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

    const profile = try noztr.nip05_identity.profile_parse_json(
        &address,
        document,
        arena.allocator(),
    );
    const verified = try noztr.nip05_identity.profile_verify_json(
        &profile.public_key,
        &address,
        document,
        arena.allocator(),
    );
    const discovery = try noztr.nip46_remote_signing.discovery_parse_well_known(
        document,
        arena.allocator(),
    );
    const connection_uri = try noztr.nip46_remote_signing.uri_serialize(
        uri_output[0..],
        .{ .client = .{
            .client_pubkey = profile.public_key,
            .relays = discovery.relays,
            .secret = "launch-secret",
        } },
    );
    const rendered = try noztr.nip46_remote_signing.discovery_render_nostrconnect_url(
        rendered_output[0..],
        discovery.nostrconnect_url.?,
        connection_uri,
        arena.allocator(),
    );

    try std.testing.expectEqualStrings(
        "https://example.com/.well-known/nostr.json?name=alice",
        lookup_url,
    );
    try std.testing.expect(verified);
    try std.testing.expectEqual(@as(usize, 1), profile.relays.len);
    try std.testing.expectEqual(@as(usize, 1), discovery.relays.len);
    try std.testing.expectEqualStrings("wss://relay.one", discovery.relays[0]);
    try std.testing.expect(std.mem.indexOf(u8, rendered, "nostrconnect://") != null);
}
