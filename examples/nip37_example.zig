const std = @import("std");
const noztr = @import("noztr");

test "NIP-37 example: encrypt validated draft JSON and parse the wrap metadata" {
    const private_key = [_]u8{
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
    };
    var pubkey: [32]u8 = undefined;
    _ = try std.fmt.hexToBytes(
        pubkey[0..],
        "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
    );
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    var encrypted: [noztr.limits.nip44_payload_base64_max_bytes]u8 = undefined;
    const draft_json = "{\"kind\":1,\"tags\":[],\"content\":\"draft\"}";
    const ciphertext = try noztr.nip37_drafts.draft_wrap_encrypt_json(
        encrypted[0..],
        &private_key,
        &pubkey,
        draft_json,
        arena.allocator(),
    );
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "d", "draft-1" } },
        .{ .items = &.{ "k", "1" } },
    };
    const event = noztr.nip01_event.Event{
        .id = [_]u8{0} ** 32,
        .pubkey = pubkey,
        .sig = [_]u8{0} ** 64,
        .kind = 31234,
        .created_at = 1,
        .content = ciphertext,
        .tags = tags[0..],
    };

    const info = try noztr.nip37_drafts.draft_wrap_parse(&event);

    try std.testing.expectEqualStrings("draft-1", info.identifier);
    try std.testing.expect(!info.is_deleted);
}

test "NIP-37 example: parse private relay list plaintext" {
    var builder_a: noztr.nip37_drafts.TagBuilder = .{};
    var builder_b: noztr.nip37_drafts.TagBuilder = .{};
    const tag_a = try noztr.nip37_drafts.private_relay_build_tag(&builder_a, "wss://relay.one");
    const tag_b = try noztr.nip37_drafts.private_relay_build_tag(&builder_b, "wss://relay.two");
    const tags = [_]noztr.nip01_event.EventTag{ tag_a, tag_b };
    var json_output: [256]u8 = undefined;
    var relays: [2][]const u8 = undefined;
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const json = try noztr.nip37_drafts.private_relay_list_serialize_json(
        json_output[0..],
        tags[0..],
    );
    const info = try noztr.nip37_drafts.private_relay_list_extract_json(
        json,
        relays[0..],
        arena.allocator(),
    );

    try std.testing.expectEqual(@as(u16, 2), info.relay_count);
    try std.testing.expectEqualStrings("wss://relay.one", relays[0]);
    try std.testing.expectEqualStrings("wss://relay.two", relays[1]);
}
