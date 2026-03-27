const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "recipe: private list helpers roundtrip without decrypt flow noise" {
    const pubkey_tag = [_][]const u8{
        "p",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    };
    const word_tag = [_][]const u8{ "word", "spam phrase" };
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = pubkey_tag[0..] },
        .{ .items = word_tag[0..] },
    };
    const public_event = common.simple_event(10000, [_]u8{0x51} ** 32, "", tags[0..]);
    var json_output: [256]u8 = undefined;
    var public_items: [2]noztr.nip51_lists.ListItem = undefined;
    const json = try noztr.nip51_lists.private_serialize_json(json_output[0..], tags[0..]);
    var items: [2]noztr.nip51_lists.ListItem = undefined;
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const public_info = try noztr.nip51_lists.extract(&public_event, public_items[0..]);
    const parsed = try noztr.nip51_lists.private_extract_json(
        10000,
        json,
        items[0..],
        arena.allocator(),
    );

    try std.testing.expectEqual(.mute_list, public_info.kind);
    try std.testing.expect(public_items[0] == .pubkey);
    try std.testing.expectEqual(.mute_list, parsed.kind);
    try std.testing.expect(items[0] == .pubkey);
    try std.testing.expect(items[1] == .word);
}
