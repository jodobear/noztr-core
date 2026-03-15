const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "adversarial media-metadata example: reject imeta without supported metadata" {
    const tag = noztr.nip01_event.EventTag{
        .items = &.{
            "imeta",
            "url https://example.com/cat.jpg",
        },
    };
    var fallbacks: [0][]const u8 = .{};

    try std.testing.expectError(
        error.MissingMetadataField,
        noztr.nip92_media_attachments.imeta_extract(tag, fallbacks[0..]),
    );
}

test "adversarial file-metadata example: reject non-canonical mime type" {
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "url", "https://example.com/cat.jpg" } },
        .{ .items = &.{ "m", "Image/JPEG" } },
        .{ .items = &.{ "x", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" } },
    };
    const event = common.simple_event(1063, [_]u8{0x94} ** 32, "cat photo", tags[0..]);
    var fallbacks: [0][]const u8 = .{};

    try std.testing.expectError(
        error.InvalidMimeTypeTag,
        noztr.nip94_file_metadata.file_metadata_extract(&event, fallbacks[0..]),
    );
}
