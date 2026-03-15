const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-B0 example: extract web bookmark metadata" {
    var identifier_tag: noztr.nipb0_web_bookmarking.BuiltTag = .{};
    var title_tag: noztr.nipb0_web_bookmarking.BuiltTag = .{};
    const built_identifier = try noztr.nipb0_web_bookmarking.web_bookmark_build_identifier_tag(
        &identifier_tag,
        "alice.blog/post",
    );
    const built_title = try noztr.nipb0_web_bookmarking.web_bookmark_build_title_tag(
        &title_tag,
        "Blog insights by Alice",
    );
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "d", "alice.blog/post" } },
        .{ .items = &.{ "title", "Blog insights by Alice" } },
        .{ .items = &.{ "published_at", "1738863000" } },
        .{ .items = &.{ "t", "post" } },
    };
    const event = common.simple_event(39701, [_]u8{0xb0} ** 32, "bookmark note", tags[0..]);
    var hashtags: [1][]const u8 = undefined;

    const parsed = try noztr.nipb0_web_bookmarking.web_bookmark_extract(&event, hashtags[0..]);

    try std.testing.expectEqualStrings("d", built_identifier.items[0]);
    try std.testing.expectEqualStrings("title", built_title.items[0]);
    try std.testing.expectEqualStrings("alice.blog/post", parsed.identifier);
    try std.testing.expectEqualStrings("Blog insights by Alice", parsed.title.?);
    try std.testing.expectEqual(@as(u64, 1738863000), parsed.published_at.?);
    try std.testing.expectEqualStrings("post", hashtags[0]);
}
