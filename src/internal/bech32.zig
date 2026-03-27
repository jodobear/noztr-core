const std = @import("std");

pub const Error = error{
    InvalidBech32,
    InvalidChecksum,
    MixedCase,
    InvalidPayload,
    BufferTooSmall,
    ValueOutOfRange,
};

pub const Decoded = struct {
    hrp: []const u8,
    payload_values: []const u8,
};

const charset = "qpzry9x8gf2tvdw0s3jn54khce6mua7l";
const generator = [_]u32{ 0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3 };

const CaseState = struct {
    saw_upper: bool = false,
    saw_lower: bool = false,
};

pub fn decode(input: []const u8, hrp_buffer: []u8, data_values_buffer: []u8) Error!Decoded {
    if (input.len > data_values_buffer.len) return error.InvalidBech32;
    if (input.len < 8) return error.InvalidBech32;

    const separator_index = std.mem.lastIndexOfScalar(u8, input, '1') orelse {
        return error.InvalidBech32;
    };
    if (separator_index == 0) return error.InvalidBech32;
    if (separator_index + 7 > input.len) return error.InvalidBech32;

    var case_state = CaseState{};
    const hrp = try normalize_hrp(input[0..separator_index], hrp_buffer, &case_state);
    const data_values = try decode_data_values(
        input[separator_index + 1 ..],
        data_values_buffer,
        &case_state,
    );
    if (!verify_checksum(hrp, data_values)) return error.InvalidChecksum;

    return .{
        .hrp = hrp,
        .payload_values = data_values[0 .. data_values.len - 6],
    };
}

pub fn encode(
    output: []u8,
    hrp: []const u8,
    payload: []const u8,
    data_values_buffer: []u8,
) Error![]const u8 {
    if (hrp.len == 0) return error.ValueOutOfRange;

    const data_len = try convert_bits(data_values_buffer, payload, 8, 5, true);
    const total_len = hrp.len + 1 + data_len + 6;
    if (output.len < total_len) return error.BufferTooSmall;

    @memcpy(output[0..hrp.len], hrp);
    output[hrp.len] = '1';
    for (data_values_buffer[0..data_len], 0..) |value, index| {
        output[hrp.len + 1 + index] = charset[value];
    }
    const checksum = create_checksum(hrp, data_values_buffer[0..data_len]);
    for (checksum, 0..) |value, index| {
        output[hrp.len + 1 + data_len + index] = charset[value];
    }
    return output[0..total_len];
}

pub fn convert_bits(
    output: []u8,
    input: []const u8,
    from_bits: u8,
    to_bits: u8,
    pad: bool,
) Error!u16 {
    std.debug.assert(from_bits > 0);
    std.debug.assert(to_bits > 0);

    var accumulator: u32 = 0;
    var bits: u8 = 0;
    var output_index: u16 = 0;
    const max_value = (@as(u32, 1) << @intCast(to_bits)) - 1;
    const from_mask = (@as(u32, 1) << @intCast(from_bits)) - 1;

    for (input) |value| {
        if ((@as(u32, value) & ~from_mask) != 0) return error.InvalidPayload;
        accumulator = (accumulator << @intCast(from_bits)) | value;
        bits += from_bits;
        while (bits >= to_bits) {
            bits -= to_bits;
            if (output_index >= output.len) return error.BufferTooSmall;
            output[output_index] = @intCast((accumulator >> @intCast(bits)) & max_value);
            output_index += 1;
        }
    }

    if (pad) {
        if (bits > 0) {
            if (output_index >= output.len) return error.BufferTooSmall;
            output[output_index] = @intCast((accumulator << @intCast(to_bits - bits)) & max_value);
            output_index += 1;
        }
        return output_index;
    }

    if (bits >= from_bits) return error.InvalidPayload;
    if (((accumulator << @intCast(to_bits - bits)) & max_value) != 0) return error.InvalidPayload;
    return output_index;
}

fn normalize_hrp(input_hrp: []const u8, hrp_buffer: []u8, case_state: *CaseState) Error![]const u8 {
    if (input_hrp.len == 0) return error.InvalidBech32;
    if (input_hrp.len > hrp_buffer.len) return error.InvalidBech32;

    for (input_hrp, 0..) |char, index| {
        hrp_buffer[index] = try normalize_char(char, case_state);
    }
    return hrp_buffer[0..input_hrp.len];
}

fn decode_data_values(
    input_data: []const u8,
    output_values: []u8,
    case_state: *CaseState,
) Error![]const u8 {
    if (input_data.len < 6) return error.InvalidBech32;
    if (input_data.len > output_values.len) return error.InvalidBech32;

    for (input_data, 0..) |char, index| {
        const lowered = try normalize_char(char, case_state);
        output_values[index] = charset_value(lowered) orelse return error.InvalidBech32;
    }
    return output_values[0..input_data.len];
}

fn normalize_char(char: u8, case_state: *CaseState) Error!u8 {
    if (char < 33 or char > 126) return error.InvalidBech32;

    var lowered = char;
    if (char >= 'A' and char <= 'Z') {
        case_state.saw_upper = true;
        lowered = char + 32;
    } else if (char >= 'a' and char <= 'z') {
        case_state.saw_lower = true;
    }
    if (case_state.saw_upper and case_state.saw_lower) return error.MixedCase;
    return lowered;
}

fn charset_value(char: u8) ?u8 {
    for (charset, 0..) |candidate, index| {
        if (candidate == char) return @intCast(index);
    }
    return null;
}

fn bech32_polymod_step(checksum: u32) u32 {
    const top = checksum >> 25;
    var next = (checksum & 0x1ffffff) << 5;
    for (generator, 0..) |value, index| {
        if (((top >> @intCast(index)) & 1) != 0) next ^= value;
    }
    return next;
}

fn checksum_with_hrp(hrp: []const u8, data_values: []const u8, add_zero_tail: bool) u32 {
    var checksum: u32 = 1;
    for (hrp) |char| {
        checksum = bech32_polymod_step(checksum) ^ (char >> 5);
    }
    checksum = bech32_polymod_step(checksum);
    for (hrp) |char| {
        checksum = bech32_polymod_step(checksum) ^ (char & 31);
    }
    for (data_values) |value| {
        checksum = bech32_polymod_step(checksum) ^ value;
    }
    if (add_zero_tail) {
        var index: u8 = 0;
        while (index < 6) : (index += 1) {
            checksum = bech32_polymod_step(checksum);
        }
    }
    return checksum;
}

fn create_checksum(hrp: []const u8, data_values: []const u8) [6]u8 {
    const polymod = checksum_with_hrp(hrp, data_values, true) ^ 1;
    var checksum: [6]u8 = undefined;
    var index: u8 = 0;
    while (index < checksum.len) : (index += 1) {
        const shift = 5 * (5 - index);
        checksum[index] = @intCast((polymod >> @intCast(shift)) & 31);
    }
    return checksum;
}

fn verify_checksum(hrp: []const u8, data_values: []const u8) bool {
    return checksum_with_hrp(hrp, data_values, false) == 1;
}

test "bech32 roundtrips lowercase payload" {
    var encoded: [64]u8 = undefined;
    var hrp_buffer: [8]u8 = undefined;
    var data_values: [64]u8 = undefined;
    var payload_output: [64]u8 = undefined;

    const payload = [_]u8{ 0x01, 0x02, 0x03, 0x04 };
    const text = try encode(encoded[0..], "test", payload[0..], data_values[0..]);
    const decoded = try decode(text, hrp_buffer[0..], data_values[0..]);
    const payload_len = try convert_bits(payload_output[0..], decoded.payload_values, 5, 8, false);

    try std.testing.expectEqualStrings("test", decoded.hrp);
    try std.testing.expectEqualSlices(u8, payload[0..], payload_output[0..payload_len]);
}
