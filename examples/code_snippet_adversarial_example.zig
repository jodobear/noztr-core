const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-C0 adversarial example: reject malformed repository references" {
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{
            "repo",
            "30023:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:nostr",
        } },
    };
    const event = common.simple_event(
        noztr.nipc0_code_snippets.code_snippet_kind,
        [_]u8{0xc0} ** 32,
        "const x = 1;",
        tags[0..],
    );
    var licenses: [0]noztr.nipc0_code_snippets.LicenseInfo = .{};
    var dependencies: [0][]const u8 = .{};
    var repo_tag: noztr.nipc0_code_snippets.BuiltTag = .{};

    try std.testing.expectError(
        error.InvalidRepoTag,
        noztr.nipc0_code_snippets.code_snippet_extract(
            &event,
            licenses[0..],
            dependencies[0..],
        ),
    );
    try std.testing.expectError(
        error.InvalidRepoTag,
        noztr.nipc0_code_snippets.code_snippet_build_repo_tag(&repo_tag, .{
            .coordinate = .{
                .pubkey = [_]u8{0} ** 32,
                .identifier = "",
            },
        }),
    );
}
