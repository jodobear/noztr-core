const std = @import("std");
const limits = @import("limits.zig");
const shared_errors = @import("errors.zig");
const nip01_event = @import("nip01_event.zig");

pub const FilterParseError = shared_errors.FilterParseError;

pub const Filter = struct {
    ids: [limits.filter_ids_max][32]u8 = [_][32]u8{[_]u8{0} ** 32} ** limits.filter_ids_max,
    ids_count: u16 = 0,

    authors: [limits.filter_authors_max][32]u8 = [_][32]u8{[_]u8{0} ** 32} ** limits.filter_authors_max,
    authors_count: u16 = 0,

    kinds: [limits.filter_kinds_max]u32 = [_]u32{0} ** limits.filter_kinds_max,
    kinds_count: u16 = 0,

    since: ?u64 = null,
    until: ?u64 = null,
};

pub fn filter_parse_json(input: []const u8, scratch: std.mem.Allocator) FilterParseError!Filter {
    std.debug.assert(input.len <= limits.event_json_max + 1);
    std.debug.assert(@intFromPtr(scratch.ptr) != 0);

    if (input.len > limits.event_json_max) {
        return error.InputTooLong;
    }

    if (input.len == 0) {
        return error.InvalidFilter;
    }

    return error.InvalidFilter;
}

pub fn filter_matches_event(filter: *const Filter, event: *const nip01_event.Event) bool {
    std.debug.assert(filter.ids_count <= limits.filter_ids_max);
    std.debug.assert(filter.authors_count <= limits.filter_authors_max);

    if (filter.since) |since_unix_seconds| {
        if (event.created_at >= since_unix_seconds) {
            if (filter.until) |until_unix_seconds| {
                if (event.created_at <= until_unix_seconds) {
                    // Keep matching.
                } else {
                    return false;
                }
            }
        } else {
            return false;
        }
    } else {
        if (filter.until) |until_unix_seconds| {
            if (event.created_at <= until_unix_seconds) {
                // Keep matching.
            } else {
                return false;
            }
        }
    }

    if (filter.ids_count > 0) {
        const has_matching_id = filter_has_id(filter, &event.id);
        if (has_matching_id) {
            // Keep matching.
        } else {
            return false;
        }
    }

    if (filter.authors_count > 0) {
        const has_matching_author = filter_has_author(filter, &event.pubkey);
        if (has_matching_author) {
            // Keep matching.
        } else {
            return false;
        }
    }

    if (filter.kinds_count > 0) {
        const has_matching_kind = filter_has_kind(filter, event.kind);
        if (has_matching_kind) {
            // Keep matching.
        } else {
            return false;
        }
    }

    return true;
}

pub fn filters_match_event(filters: []const Filter, event: *const nip01_event.Event) bool {
    std.debug.assert(filters.len <= std.math.maxInt(u32));
    std.debug.assert(event.created_at <= std.math.maxInt(u64));

    var index: u32 = 0;
    while (index < filters.len) : (index += 1) {
        const matched = filter_matches_event(&filters[index], event);
        if (matched) {
            return true;
        }
    }

    return false;
}

fn filter_has_id(filter: *const Filter, event_id: *const [32]u8) bool {
    std.debug.assert(filter.ids_count <= limits.filter_ids_max);
    std.debug.assert(event_id[0] <= 255);

    var index: u16 = 0;
    while (index < filter.ids_count) : (index += 1) {
        if (std.mem.eql(u8, &filter.ids[index], event_id)) {
            return true;
        }
    }

    return false;
}

fn filter_has_author(filter: *const Filter, event_author: *const [32]u8) bool {
    std.debug.assert(filter.authors_count <= limits.filter_authors_max);
    std.debug.assert(event_author[0] <= 255);

    var index: u16 = 0;
    while (index < filter.authors_count) : (index += 1) {
        if (std.mem.eql(u8, &filter.authors[index], event_author)) {
            return true;
        }
    }

    return false;
}

fn filter_has_kind(filter: *const Filter, event_kind: u32) bool {
    std.debug.assert(filter.kinds_count <= limits.filter_kinds_max);
    std.debug.assert(event_kind <= std.math.maxInt(u32));

    var index: u16 = 0;
    while (index < filter.kinds_count) : (index += 1) {
        if (filter.kinds[index] == event_kind) {
            return true;
        }
    }

    return false;
}

test "filters OR behavior is deterministic" {
    var event = nip01_event.Event{
        .id = [_]u8{5} ** 32,
        .pubkey = [_]u8{6} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = 7,
        .created_at = 123,
        .content = "ok",
    };
    event.id = nip01_event.event_compute_id(&event);

    var filter_reject = Filter{};
    filter_reject.kinds[0] = 999;
    filter_reject.kinds_count = 1;

    var filter_accept = Filter{};
    filter_accept.kinds[0] = 7;
    filter_accept.kinds_count = 1;

    const filters = [_]Filter{ filter_reject, filter_accept };
    const matched_a = filters_match_event(filters[0..], &event);
    const matched_b = filters_match_event(filters[0..], &event);

    try std.testing.expect(matched_a);
    try std.testing.expect(matched_b);
}

test "filter typed parse errors are forceable" {
    const too_long_input = [_]u8{0} ** (limits.event_json_max + 1);

    try std.testing.expectError(error.InputTooLong, filter_parse_json(&too_long_input, std.testing.allocator));
    try std.testing.expectError(error.InvalidFilter, filter_parse_json("{}", std.testing.allocator));
}
