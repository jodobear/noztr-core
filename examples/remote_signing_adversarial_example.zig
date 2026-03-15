const std = @import("std");
const noztr = @import("noztr");

test "adversarial remote-signing example: reject discovery template without placeholder" {
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
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    try std.testing.expectError(
        error.InvalidNostrConnectUrl,
        noztr.nip46_remote_signing.discovery_render_nostrconnect_url(
            rendered_output[0..],
            "https://bunker.example/connect/static",
            connection_uri,
            arena.allocator(),
        ),
    );
}
