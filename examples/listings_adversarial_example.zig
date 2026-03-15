const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "adversarial listing example: reject full url identifier on builder path" {
    var built_tag: noztr.nip99_classified_listings.BuiltTag = .{};

    try std.testing.expectError(
        error.InvalidIdentifierTag,
        noztr.nip99_classified_listings.listing_build_identifier_tag(
            &built_tag,
            "https://example.com/post",
        ),
    );
}

test "adversarial listing example: reject non-url identifier on extract path" {
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "d", "not a url id" } },
    };
    const event = common.simple_event(30402, [_]u8{0x99} ** 32, "bike details", tags[0..]);
    var images: [0]noztr.nip99_classified_listings.ImageInfo = .{};
    var hashtags: [0][]const u8 = .{};

    try std.testing.expectError(
        error.InvalidIdentifierTag,
        noztr.nip99_classified_listings.listing_extract(&event, images[0..], hashtags[0..]),
    );
}
