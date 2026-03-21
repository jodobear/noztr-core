const std = @import("std");

pub fn parse(text: []const u8, max_len: usize) error{InvalidUrl}![]const u8 {
    std.debug.assert(max_len > 0);

    if (text.len == 0) return error.InvalidUrl;
    if (text.len > max_len) return error.InvalidUrl;

    const parsed = std.Uri.parse(text) catch return error.InvalidUrl;
    if (parsed.scheme.len == 0) return error.InvalidUrl;
    if (parsed.host == null) return error.InvalidUrl;
    return text;
}

test "host-required URL parser rejects empty and schemeless inputs" {
    try std.testing.expectError(error.InvalidUrl, parse("", 128));
    try std.testing.expectError(error.InvalidUrl, parse("example.com/path", 128));
}

test "host-required URL parser rejects scheme-only inputs" {
    try std.testing.expectError(error.InvalidUrl, parse("mailto:test@example.com", 128));
}

test "host-required URL parser accepts canonical https URL" {
    try std.testing.expectEqualStrings("https://example.com/a", try parse("https://example.com/a", 128));
}
