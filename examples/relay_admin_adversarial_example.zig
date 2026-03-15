const std = @import("std");
const noztr = @import("noztr");

test "adversarial relay-admin example: reject invalid control text on serializer path" {
    var output: [256]u8 = undefined;

    try std.testing.expectError(
        error.InvalidText,
        noztr.nip86_relay_management.request_serialize_json(
            output[0..],
            .{ .changerelayname = "bad\x01name" },
        ),
    );
}
