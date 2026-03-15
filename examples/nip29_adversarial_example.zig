const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "adversarial group reducer example: reject mixed-group moderation replay" {
    const metadata_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "d", "pizza-lovers" } },
    };
    const put_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "h", "other-group" } },
        .{ .items = &.{
            "p",
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
            "moderator",
        } },
        .{ .items = &.{ "previous", "deadbeef" } },
    };
    var users: [1]noztr.nip29_relay_groups.GroupStateUser = undefined;
    var roles: [0]noztr.nip29_relay_groups.GroupRole = .{};
    var user_roles: [noztr.nip29_relay_groups.group_state_user_roles_max][]const u8 = undefined;
    var state = noztr.nip29_relay_groups.GroupState.init(users[0..], roles[0..], user_roles[0..]);

    state.reset();
    try noztr.nip29_relay_groups.group_state_apply_event(
        &state,
        &common.simple_event(39000, [_]u8{0x29} ** 32, "", metadata_tags[0..]),
    );
    try std.testing.expectError(
        error.GroupStateMismatch,
        noztr.nip29_relay_groups.group_state_apply_event(
            &state,
            &common.simple_event(9000, [_]u8{0x29} ** 32, "promote", put_tags[0..]),
        ),
    );
}
