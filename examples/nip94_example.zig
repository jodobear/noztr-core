const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-94 example: extract file metadata and fallbacks" {
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "url", "https://example.com/cat.jpg" } },
        .{ .items = &.{ "m", "image/jpeg" } },
        .{ .items = &.{ "x", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" } },
        .{ .items = &.{ "fallback", "https://backup.example/cat.jpg" } },
    };
    const event = common.simple_event(1063, [_]u8{0x94} ** 32, "cat photo", tags[0..]);
    var fallbacks: [1][]const u8 = undefined;

    const parsed = try noztr.nip94_file_metadata.file_metadata_extract(&event, fallbacks[0..]);

    try std.testing.expectEqualStrings("https://example.com/cat.jpg", parsed.url);
    try std.testing.expectEqualStrings("image/jpeg", parsed.mime_type);
    try std.testing.expectEqual(@as(u16, 1), parsed.fallback_count);
    try std.testing.expectEqualStrings("https://backup.example/cat.jpg", fallbacks[0]);
}
