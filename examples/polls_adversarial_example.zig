const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-88 adversarial example: latest invalid singlechoice response counts zero" {
    const poll_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "option", "opt1", "Red" } },
        .{ .items = &.{ "option", "opt2", "Blue" } },
    };
    const poll_event = common.simple_event(
        noztr.nip88_polls.poll_kind,
        [_]u8{0x88} ** 32,
        "Favorite color?",
        poll_tags[0..],
    );
    const older_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "e", "0000000000000000000000000000000000000000000000000000000000000000" } },
        .{ .items = &.{ "response", "opt1" } },
    };
    const newer_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "e", "0000000000000000000000000000000000000000000000000000000000000000" } },
        .{ .items = &.{ "response", "unknown" } },
    };
    const responses = [_]noztr.nip01_event.Event{
        .{
            .id = [_]u8{1} ** 32,
            .pubkey = [_]u8{9} ** 32,
            .sig = [_]u8{0} ** 64,
            .kind = noztr.nip88_polls.poll_response_kind,
            .created_at = 10,
            .content = "",
            .tags = older_tags[0..],
        },
        .{
            .id = [_]u8{2} ** 32,
            .pubkey = [_]u8{9} ** 32,
            .sig = [_]u8{0} ** 64,
            .kind = noztr.nip88_polls.poll_response_kind,
            .created_at = 20,
            .content = "",
            .tags = newer_tags[0..],
        },
    };
    var latest: [2]noztr.nip88_polls.CountedResponse = undefined;
    var tallies: [2]noztr.nip88_polls.OptionTally = undefined;
    var bad_response_tag: noztr.nip88_polls.TagBuilder = .{};

    const tally = try noztr.nip88_polls.poll_tally_reduce(
        &poll_event,
        responses[0..],
        latest[0..],
        tallies[0..],
    );

    try std.testing.expectEqual(@as(u16, 1), tally.candidate_pubkey_count);
    try std.testing.expectEqual(@as(u16, 0), tally.counted_pubkey_count);
    try std.testing.expectEqual(@as(u32, 0), tallies[0].vote_count);
    try std.testing.expectEqual(@as(u32, 0), tallies[1].vote_count);
    try std.testing.expectError(
        error.InvalidResponseTag,
        noztr.nip88_polls.poll_response_build_response_tag(&bad_response_tag, "not-valid!"),
    );
}
