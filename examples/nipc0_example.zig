const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-C0 example: extract code snippet metadata" {
    var name_tag: noztr.nipc0_code_snippets.TagBuilder = .{};
    var repo_tag: noztr.nipc0_code_snippets.TagBuilder = .{};
    const built_name = try noztr.nipc0_code_snippets.code_snippet_build_name_tag(
        &name_tag,
        "hello.zig",
    );
    const built_repo = try noztr.nipc0_code_snippets.code_snippet_build_repo_tag(&repo_tag, .{
        .url = "https://github.com/nostr-protocol/nips",
    });
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "l", "zig" } },
        .{ .items = &.{ "name", "hello.zig" } },
        .{ .items = &.{ "extension", "zig" } },
        .{ .items = &.{ "license", "MIT" } },
        .{ .items = &.{ "repo", "https://github.com/nostr-protocol/nips" } },
        .{ .items = &.{ "dep", "std" } },
    };
    const event = common.simple_event(
        noztr.nipc0_code_snippets.code_snippet_kind,
        [_]u8{0xc0} ** 32,
        "const std = @import(\"std\");",
        tags[0..],
    );
    var licenses: [1]noztr.nipc0_code_snippets.License = undefined;
    var dependencies: [1][]const u8 = undefined;

    const parsed = try noztr.nipc0_code_snippets.code_snippet_extract(
        &event,
        licenses[0..],
        dependencies[0..],
    );

    try std.testing.expectEqualStrings("name", built_name.items[0]);
    try std.testing.expectEqualStrings("repo", built_repo.items[0]);
    try std.testing.expectEqualStrings("zig", parsed.language.?);
    try std.testing.expectEqualStrings("hello.zig", parsed.name.?);
    try std.testing.expectEqualStrings("zig", parsed.extension.?);
    try std.testing.expectEqual(@as(u16, 1), parsed.license_count);
    try std.testing.expectEqual(@as(u16, 1), parsed.dependency_count);
    try std.testing.expectEqualStrings("MIT", licenses[0].identifier);
    try std.testing.expectEqualStrings("std", dependencies[0]);
}
