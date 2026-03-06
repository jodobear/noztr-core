const std = @import("std");

/// Strict-by-default shared limits used by v1 module contracts.
pub const limits = @import("limits.zig");

/// Strict-by-default typed errors used by v1 module contracts.
pub const errors = @import("errors.zig");

/// Phase I1 concrete export for the NIP-01 event module.
pub const nip01_event = @import("nip01_event.zig");

/// Phase I1 concrete export for the NIP-01 filter module.
pub const nip01_filter = @import("nip01_filter.zig");

fn use_typed_error_for_smoke(fail: bool) errors.EventVerifyError!void {
    std.debug.assert(fail);
    std.debug.assert(!@inComptime());

    if (fail) {
        return error.InvalidId;
    }

    return;
}

test "root exports limits and error namespaces" {
    try std.testing.expect(limits.event_json_max >= limits.content_bytes_max);
    try std.testing.expect(@TypeOf(nip01_event.EventParseError) == type);
    try std.testing.expect(@TypeOf(nip01_filter.FilterParseError) == type);
}

test "root smoke test uses typed errors" {
    try std.testing.expectError(error.InvalidId, use_typed_error_for_smoke(true));
}
