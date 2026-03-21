const std = @import("std");
const noztr = @import("noztr");

test "NIP-04 adversarial example: malformed payloads and duplicate recipients stay typed" {
    var recipient_tag: noztr.nip04.BuiltTag = .{};
    const overlong_pubkey =
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdefx";

    try std.testing.expectError(
        error.InvalidRecipientTag,
        noztr.nip04.nip04_build_recipient_tag(&recipient_tag, overlong_pubkey),
    );

    const malformed_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{
            "p",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        } },
    };
    const malformed_event = noztr.nip01_event.Event{
        .id = [_]u8{0} ** 32,
        .pubkey = [_]u8{0x11} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = 4,
        .created_at = 1,
        .content = "AAAAAAAAAAAAAAAAAAAAAA==?iv=AAAAAAAAAAAAAAAAAAAA%%==",
        .tags = malformed_tags[0..],
    };
    try std.testing.expectError(
        error.InvalidBase64,
        noztr.nip04.nip04_message_parse(&malformed_event),
    );

    const duplicate_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{
            "p",
            "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        } },
        .{ .items = &.{
            "p",
            "fedcba9876543210fedcba9876543210fedcba9876543210fedcba9876543210",
        } },
    };
    const duplicate_event = noztr.nip01_event.Event{
        .id = [_]u8{0} ** 32,
        .pubkey = [_]u8{0x11} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = 4,
        .created_at = 1,
        .content = "AAAAAAAAAAAAAAAAAAAAAA==?iv=AAAAAAAAAAAAAAAAAAAAAA==",
        .tags = duplicate_tags[0..],
    };
    try std.testing.expectError(error.DuplicateRecipientTag, noztr.nip04.nip04_message_parse(&duplicate_event));
}
