const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "adversarial private-list example: reject deprecated NIP-04 content" {
    const event = common.simple_event(
        10000,
        [_]u8{0x51} ** 32,
        "legacy?iv=deadbeef",
        &.{},
    );
    const private_key = [_]u8{0x11} ** 32;
    var plaintext: [256]u8 = undefined;
    var items: [1]noztr.nip51_lists.ListItem = undefined;
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    try std.testing.expectError(
        error.UnsupportedPrivateEncoding,
        noztr.nip51_lists.list_private_extract_nip44(
            plaintext[0..],
            &event,
            &private_key,
            items[0..],
            arena.allocator(),
        ),
    );
}

test "adversarial private-relay example: reject non-websocket relay urls" {
    var relays: [1][]const u8 = undefined;
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    try std.testing.expectError(
        error.InvalidPrivateRelayUrl,
        noztr.nip37_drafts.relay_list_extract_json(
            "[[\"relay\",\"https://relay.one\"]]",
            relays[0..],
            arena.allocator(),
        ),
    );
}
