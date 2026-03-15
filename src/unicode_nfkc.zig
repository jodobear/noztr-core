const std = @import("std");
const limits = @import("limits.zig");
const unicode_nfkd = @import("unicode_nfkd.zig");
const nfkd_data = @import("unicode_nfkd_data.zig");
const data = @import("unicode_nfkc_data.zig");

const hangul_s_base: u32 = 0xAC00;
const hangul_l_base: u32 = 0x1100;
const hangul_v_base: u32 = 0x1161;
const hangul_t_base: u32 = 0x11A7;
const hangul_l_count: u32 = 19;
const hangul_v_count: u32 = 21;
const hangul_t_count: u32 = 28;
const hangul_n_count: u32 = hangul_v_count * hangul_t_count;
const hangul_s_count: u32 = hangul_l_count * hangul_n_count;

comptime {
    std.debug.assert(std.mem.eql(u8, data.unicode_version, nfkd_data.unicode_version));
}

pub const UnicodeNfkcError = error{
    InvalidUtf8,
    BufferTooSmall,
    InvalidNormalization,
};

pub fn normalize(output: []u8, input: []const u8) UnicodeNfkcError![]const u8 {
    std.debug.assert(output.len <= limits.nip49_password_normalized_bytes_max);
    std.debug.assert(input.len <= limits.nip49_password_bytes_max);

    var decomposed_bytes: [limits.nip49_password_normalized_bytes_max]u8 = undefined;
    const decomposed = unicode_nfkd.normalize(decomposed_bytes[0..], input) catch |err| {
        return switch (err) {
            error.InvalidUtf8 => error.InvalidUtf8,
            error.BufferTooSmall => error.InvalidNormalization,
            error.InvalidNormalization => error.InvalidNormalization,
        };
    };

    var scalars: [limits.nip49_password_normalized_bytes_max]u32 = undefined;
    const scalar_count = try decode_scalars(scalars[0..], decomposed);
    const composed_count = try compose_scalars(scalars[0..scalar_count]);
    return try encode_scalars(output, scalars[0..composed_count]);
}

fn decode_scalars(output: []u32, input: []const u8) UnicodeNfkcError!u16 {
    std.debug.assert(output.len >= limits.nip49_password_normalized_bytes_max);
    std.debug.assert(input.len <= limits.nip49_password_normalized_bytes_max);

    var iterator = std.unicode.Utf8Iterator{ .bytes = input, .i = 0 };
    var count: u16 = 0;
    while (iterator.nextCodepoint()) |cp| {
        if (count == output.len) return error.InvalidNormalization;
        output[count] = cp;
        count += 1;
    }
    return count;
}

fn compose_scalars(scalars: []u32) UnicodeNfkcError!u16 {
    std.debug.assert(scalars.len <= limits.nip49_password_normalized_bytes_max);
    std.debug.assert(scalars.len == 0 or scalars[0] <= 0x10FFFF);

    var write_index: u16 = 0;
    var starter_index: ?u16 = null;
    var starter: u32 = 0;
    var last_ccc: u8 = 0;

    for (scalars) |cp| {
        const ccc = combining_class(cp);
        if (starter_index) |index| {
            if (try_compose_pair(starter, cp)) |composed| {
                if (last_ccc == 0 or last_ccc < ccc) {
                    scalars[index] = composed;
                    starter = composed;
                    continue;
                }
            }
        }
        scalars[write_index] = cp;
        if (ccc == 0) {
            starter_index = write_index;
            starter = cp;
            last_ccc = 0;
        } else {
            last_ccc = ccc;
        }
        write_index += 1;
    }
    return write_index;
}

fn try_compose_pair(starter: u32, combining: u32) ?u32 {
    std.debug.assert(starter <= 0x10FFFF);
    std.debug.assert(combining <= 0x10FFFF);

    if (hangul_compose(starter, combining)) |composed| return composed;
    return find_composition(starter, combining);
}

fn hangul_compose(starter: u32, combining: u32) ?u32 {
    std.debug.assert(starter <= 0x10FFFF);
    std.debug.assert(combining <= 0x10FFFF);

    if (starter >= hangul_l_base and starter < hangul_l_base + hangul_l_count) {
        if (combining >= hangul_v_base and combining < hangul_v_base + hangul_v_count) {
            const l_index = starter - hangul_l_base;
            const v_index = combining - hangul_v_base;
            return hangul_s_base + (l_index * hangul_v_count + v_index) * hangul_t_count;
        }
    }
    if (starter >= hangul_s_base and starter < hangul_s_base + hangul_s_count) {
        if (@mod(starter - hangul_s_base, hangul_t_count) == 0) {
            if (combining > hangul_t_base and combining < hangul_t_base + hangul_t_count) {
                return starter + combining - hangul_t_base;
            }
        }
    }
    return null;
}

fn find_composition(starter: u32, combining: u32) ?u32 {
    std.debug.assert(starter <= 0x10FFFF);
    std.debug.assert(combining <= 0x10FFFF);

    var low: usize = 0;
    var high: usize = data.composition_entries.len;
    while (low < high) {
        const mid = low + @divTrunc(high - low, 2);
        const entry = data.composition_entries[mid];
        if (entry.starter == starter and entry.combining == combining) return entry.composed;
        if (entry.starter < starter) {
            low = mid + 1;
            continue;
        }
        if (entry.starter > starter) {
            high = mid;
            continue;
        }
        if (entry.combining < combining) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return null;
}

fn combining_class(cp: u32) u8 {
    std.debug.assert(cp <= 0x10FFFF);
    std.debug.assert(nfkd_data.combining_entries.len > 0);

    var low: usize = 0;
    var high: usize = nfkd_data.combining_entries.len;
    while (low < high) {
        const mid = low + @divTrunc(high - low, 2);
        const entry = nfkd_data.combining_entries[mid];
        if (entry.cp == cp) return entry.ccc;
        if (entry.cp < cp) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return 0;
}

fn encode_scalars(output: []u8, scalars: []const u32) UnicodeNfkcError![]const u8 {
    std.debug.assert(output.len <= limits.nip49_password_normalized_bytes_max);
    std.debug.assert(scalars.len <= limits.nip49_password_normalized_bytes_max);

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

test "nfkc normalizes the published NIP-49 password example" {
    var output: [limits.nip49_password_normalized_bytes_max]u8 = undefined;

    try std.testing.expectEqualStrings("ÅΩṩ", try normalize(output[0..], "ÅΩẛ̣"));
    try std.testing.expectEqualStrings("ABC", try normalize(output[0..], "ＡＢＣ"));
}

test "nfkc composes hangul and rejects invalid utf8" {
    var output: [limits.nip49_password_normalized_bytes_max]u8 = undefined;

    try std.testing.expectEqualStrings("각", try normalize(output[0..], "각"));
    try std.testing.expectError(error.InvalidUtf8, normalize(output[0..], "\xFF"));
}
