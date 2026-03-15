const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-88 example: extract poll metadata and tally latest votes" {
    var option_tag: noztr.nip88_polls.BuiltTag = .{};
    var response_tag: noztr.nip88_polls.BuiltTag = .{};
    const built_option = try noztr.nip88_polls.poll_build_option_tag(
        &option_tag,
        .{ .id = "opt1", .label = "Red" },
    );
    const built_response = try noztr.nip88_polls.poll_response_build_response_tag(
        &response_tag,
        "opt1",
    );
    const poll_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "option", "opt1", "Red" } },
        .{ .items = &.{ "option", "opt2", "Blue" } },
        .{ .items = &.{ "polltype", "singlechoice" } },
    };
    const poll_event = common.simple_event(
        noztr.nip88_polls.poll_kind,
        [_]u8{0x88} ** 32,
        "Favorite color?",
        poll_tags[0..],
    );
    const response_tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "e", "0000000000000000000000000000000000000000000000000000000000000000" } },
        .{ .items = &.{ "response", "opt1" } },
    };
    const response_event = common.simple_event(
        noztr.nip88_polls.poll_response_kind,
        [_]u8{0x44} ** 32,
        "",
        response_tags[0..],
    );
    var options: [2]noztr.nip88_polls.PollOption = undefined;
    var relays: [0][]const u8 = .{};
    var latest: [1]noztr.nip88_polls.CountedResponse = undefined;
    var tallies: [2]noztr.nip88_polls.OptionTally = undefined;

    const poll = try noztr.nip88_polls.poll_extract(&poll_event, options[0..], relays[0..]);
    const tally = try noztr.nip88_polls.poll_tally_reduce(
        &poll_event,
        &.{response_event},
        latest[0..],
        tallies[0..],
    );

    try std.testing.expectEqualStrings("option", built_option.items[0]);
    try std.testing.expectEqualStrings("response", built_response.items[0]);
    try std.testing.expectEqual(PollType.singlechoice, poll.poll_type);
    try std.testing.expectEqual(@as(u16, 2), poll.option_count);
    try std.testing.expectEqual(@as(u16, 1), tally.counted_pubkey_count);
    try std.testing.expectEqual(@as(u32, 1), tallies[0].vote_count);
    try std.testing.expectEqual(@as(u32, 0), tallies[1].vote_count);
}

const PollType = noztr.nip88_polls.PollType;
