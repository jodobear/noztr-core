const std = @import("std");
const noztr = @import("noztr");

test "adversarial NIP-37 example: overlong private relay builder input stays typed" {
    var built_tag: noztr.nip37_drafts.TagBuilder = .{};
    const overlong_relay = "wss://" ++ ("a" ** 9000) ++ ".example";

    try std.testing.expectError(
        error.InvalidPrivateRelayUrl,
        noztr.nip37_drafts.relay_build_tag(&built_tag, overlong_relay),
    );
}
