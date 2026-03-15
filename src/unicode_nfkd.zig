const std = @import("std");
const limits = @import("limits.zig");
const data = @import("unicode_nfkd_data.zig");

const hangul_s_base: u32 = 0xAC00;
const hangul_l_base: u32 = 0x1100;
const hangul_v_base: u32 = 0x1161;
const hangul_t_base: u32 = 0x11A7;
const hangul_l_count: u32 = 19;
const hangul_v_count: u32 = 21;
const hangul_t_count: u32 = 28;
const hangul_n_count: u32 = hangul_v_count * hangul_t_count;
const hangul_s_count: u32 = hangul_l_count * hangul_n_count;

pub const UnicodeNfkdError = error{
    InvalidUtf8,
    BufferTooSmall,
    InvalidNormalization,
};

pub fn normalize(output: []u8, input: []const u8) UnicodeNfkdError![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(input.len <= limits.content_bytes_max);

    if (!std.unicode.utf8ValidateSlice(input)) return error.InvalidUtf8;

    var scalars: [limits.nip06_normalized_bytes_max]u32 = undefined;
    const scalar_count = try decompose_scalars(scalars[0..], input);
    return try encode_scalars(output, scalars[0..scalar_count]);
}

fn decompose_scalars(output: []u32, input: []const u8) UnicodeNfkdError!u16 {
    std.debug.assert(output.len >= limits.nip06_normalized_bytes_max);
    std.debug.assert(input.len <= limits.content_bytes_max);

    var iterator = std.unicode.Utf8Iterator{ .bytes = input, .i = 0 };
    var count: u16 = 0;
    var segment_start: u16 = 0;
    while (iterator.nextCodepoint()) |cp| {
        if (hangul_decompose(cp, output, &count, &segment_start)) continue;
        if (find_mapping(cp)) |entry| {
            const start: usize = @intCast(entry.offset);
            const end: usize = @intCast(entry.offset + entry.len);
            for (data.mapping_scalars[start..end]) |mapped| {
                try append_scalar(output, &count, &segment_start, mapped);
            }
            continue;
        }
        try append_scalar(output, &count, &segment_start, cp);
    }
    return count;
}

fn hangul_decompose(
    cp: u32,
    output: []u32,
    count: *u16,
    segment_start: *u16,
) bool {
    std.debug.assert(output.len >= limits.nip06_normalized_bytes_max);
    std.debug.assert(count.* <= output.len);

    if (cp < hangul_s_base or cp >= hangul_s_base + hangul_s_count) return false;

    const s_index = cp - hangul_s_base;
    const l_index = @divTrunc(s_index, hangul_n_count);
    const v_index = @divTrunc(@mod(s_index, hangul_n_count), hangul_t_count);
    const t_index = @mod(s_index, hangul_t_count);
    append_scalar(output, count, segment_start, hangul_l_base + l_index) catch unreachable;
    append_scalar(output, count, segment_start, hangul_v_base + v_index) catch unreachable;
    if (t_index != 0) {
        append_scalar(output, count, segment_start, hangul_t_base + t_index) catch unreachable;
    }
    return true;
}

fn append_scalar(
    output: []u32,
    count: *u16,
    segment_start: *u16,
    cp: u32,
) UnicodeNfkdError!void {
    std.debug.assert(output.len >= limits.nip06_normalized_bytes_max);
    std.debug.assert(count.* <= output.len);

    const count_index: usize = @intCast(count.*);
    if (count_index >= output.len) return error.InvalidNormalization;
    output[count_index] = cp;
    count.* += 1;
    const ccc = combining_class(cp);
    if (ccc == 0) {
        segment_start.* = count.* - 1;
        return;
    }

    var index = count.* - 1;
    while (index > segment_start.*) : (index -= 1) {
        const previous = output[index - 1];
        const previous_ccc = combining_class(previous);
        if (previous_ccc <= ccc or previous_ccc == 0) break;
        output[index] = previous;
        output[index - 1] = cp;
    }
}

fn encode_scalars(output: []u8, scalars: []const u32) UnicodeNfkdError![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(scalars.len <= limits.nip06_normalized_bytes_max);

    var index: usize = 0;
    for (scalars) |cp| {
        var utf8: [4]u8 = undefined;
        const encoded = std.unicode.utf8Encode(@intCast(cp), &utf8) catch {
            return error.InvalidNormalization;
        };
        if (index + encoded > output.len) return error.BufferTooSmall;
        @memcpy(output[index .. index + encoded], utf8[0..encoded]);
        index += encoded;
    }
    return output[0..index];
}

fn find_mapping(cp: u32) ?data.MappingEntry {
    std.debug.assert(cp <= 0x10FFFF);
    std.debug.assert(data.mapping_entries.len > 0);

    var low: usize = 0;
    var high: usize = data.mapping_entries.len;
    while (low < high) {
        const mid = low + @divTrunc(high - low, 2);
        const entry = data.mapping_entries[mid];
        if (entry.cp == cp) return entry;
        if (entry.cp < cp) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return null;
}

fn combining_class(cp: u32) u8 {
    std.debug.assert(cp <= 0x10FFFF);
    std.debug.assert(data.combining_entries.len > 0);

    var low: usize = 0;
    var high: usize = data.combining_entries.len;
    while (low < high) {
        const mid = low + @divTrunc(high - low, 2);
        const entry = data.combining_entries[mid];
        if (entry.cp == cp) return entry.ccc;
        if (entry.cp < cp) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return 0;
}

test "nfkd normalizes representative compatibility cases" {
    var output: [limits.nip06_normalized_bytes_max]u8 = undefined;

    try std.testing.expectEqualStrings("Trézor", try normalize(output[0..], "Trézor"));
    try std.testing.expectEqualStrings("パスフレーズ", try normalize(output[0..], "パスフレーズ"));
    try std.testing.expectEqualStrings("ABC", try normalize(output[0..], "ＡＢＣ"));
    try std.testing.expectEqualStrings("kg", try normalize(output[0..], "㎏"));
}

test "nfkd normalizes hangul and combining order" {
    var output: [limits.nip06_normalized_bytes_max]u8 = undefined;

    try std.testing.expectEqualStrings("각", try normalize(output[0..], "각"));
    try std.testing.expectEqualStrings("Å", try normalize(output[0..], "Å"));
}
