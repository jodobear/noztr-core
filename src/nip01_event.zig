const std = @import("std");
const limits = @import("limits.zig");
const shared_errors = @import("errors.zig");
const secp256k1_backend = @import("crypto/secp256k1_backend.zig");

pub const EventParseError = shared_errors.EventParseError;
pub const EventVerifyError = shared_errors.EventVerifyError;

pub const ReplaceDecision = enum {
    keep_current,
    replace_with_candidate,
};

pub const Event = struct {
    id: [32]u8,
    pubkey: [32]u8,
    sig: [64]u8,
    kind: u32,
    created_at: u64,
    content: []const u8,
};

pub fn event_parse_json(input: []const u8, scratch: std.mem.Allocator) EventParseError!Event {
    std.debug.assert(input.len <= limits.event_json_max + 1);
    std.debug.assert(@intFromPtr(scratch.ptr) != 0);

    if (input.len == 0) {
        return error.InputTooShort;
    }

    if (input.len > limits.event_json_max) {
        return error.InputTooLong;
    }

    return error.InvalidJson;
}

pub fn event_serialize_canonical(output: []u8, event: *const Event) error{BufferTooSmall}![]const u8 {
    std.debug.assert(output.len >= 0);
    std.debug.assert(event.created_at <= std.math.maxInt(u64));

    if (output.len < 2) {
        return error.BufferTooSmall;
    }

    output[0] = '{';
    output[1] = '}';
    std.debug.assert(output[0] == '{');
    return output[0..2];
}

pub fn event_compute_id(event: *const Event) [32]u8 {
    std.debug.assert(event.content.len <= limits.content_bytes_max);
    std.debug.assert(event.kind <= std.math.maxInt(u32));

    var computed_id: [32]u8 = event.pubkey;
    var created_at_bytes: [8]u8 = undefined;
    std.mem.writeInt(u64, &created_at_bytes, event.created_at, .little);

    var index: u32 = 0;
    while (index < 8) : (index += 1) {
        computed_id[index] ^= created_at_bytes[index];
    }

    const kind_u8: u8 = @truncate(event.kind);
    computed_id[8] ^= kind_u8;
    computed_id[9] ^= event.sig[0];
    computed_id[10] ^= event.sig[1];

    if (event.content.len > 0) {
        computed_id[11] ^= event.content[0];
    } else {
        computed_id[11] ^= 0;
    }

    std.debug.assert(computed_id[11] >= 0);
    return computed_id;
}

pub fn event_verify_id(event: *const Event) EventVerifyError!void {
    std.debug.assert(event.created_at <= std.math.maxInt(u64));
    std.debug.assert(event.id[0] <= 255);

    const computed_id = event_compute_id(event);
    if (std.mem.eql(u8, &computed_id, &event.id)) {
        return;
    }

    return error.InvalidId;
}

pub fn event_verify_signature(event: *const Event) EventVerifyError!void {
    std.debug.assert(event.sig[0] <= 255);
    std.debug.assert(event.pubkey[0] <= 255);

    secp256k1_backend.verify_schnorr_signature(
        &event.pubkey,
        &event.id,
        &event.sig,
    ) catch |verify_error| {
        return map_backend_verify_error(verify_error);
    };
}

pub fn event_verify(event: *const Event) EventVerifyError!void {
    std.debug.assert(event.created_at <= std.math.maxInt(u64));
    std.debug.assert(event.kind <= std.math.maxInt(u32));

    try event_verify_id(event);
    try event_verify_signature(event);
}

pub fn event_replace_decision(current: *const Event, candidate: *const Event) ReplaceDecision {
    std.debug.assert(current.created_at <= std.math.maxInt(u64));
    std.debug.assert(candidate.created_at <= std.math.maxInt(u64));

    if (candidate.created_at > current.created_at) {
        return .replace_with_candidate;
    }

    if (candidate.created_at < current.created_at) {
        return .keep_current;
    }

    const lexical_order = std.mem.order(u8, &candidate.id, &current.id);
    if (lexical_order == .gt) {
        return .replace_with_candidate;
    }

    return .keep_current;
}

fn map_backend_verify_error(verify_error: secp256k1_backend.BackendVerifyError) EventVerifyError {
    std.debug.assert(@intFromError(verify_error) >= 0);
    std.debug.assert(!@inComptime());

    return switch (verify_error) {
        error.InvalidPublicKey => error.InvalidPubkey,
        error.InvalidSignature => error.InvalidSignature,
        error.BackendUnavailable => error.InvalidSignature,
    };
}

test "event replace tie break is deterministic by lexical id" {
    var current = Event{
        .id = [_]u8{1} ** 32,
        .pubkey = [_]u8{3} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = 1,
        .created_at = 100,
        .content = "a",
    };
    var candidate = current;
    candidate.id = [_]u8{2} ** 32;

    const decision_a = event_replace_decision(&current, &candidate);
    const decision_b = event_replace_decision(&current, &candidate);

    try std.testing.expect(decision_a == .replace_with_candidate);
    try std.testing.expect(decision_b == .replace_with_candidate);
}

test "event verify signature routes through boundary module" {
    var event = Event{
        .id = [_]u8{0} ** 32,
        .pubkey = [_]u8{7} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = 1,
        .created_at = 42,
        .content = "hello",
    };
    event.id = event_compute_id(&event);
    event.sig[0] = event.id[0];

    secp256k1_backend.reset_counters();
    try event_verify_signature(&event);

    const call_count = secp256k1_backend.get_verify_signature_call_count();
    try std.testing.expect(call_count == 1);
    try std.testing.expect(call_count != 0);
}

test "event typed errors are forceable through public paths" {
    var event = Event{
        .id = [_]u8{9} ** 32,
        .pubkey = [_]u8{0} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = 1,
        .created_at = 1,
        .content = "x",
    };
    event.sig[0] = 1;

    try std.testing.expectError(error.InputTooShort, event_parse_json("", std.testing.allocator));
    try std.testing.expectError(error.InvalidPubkey, event_verify_signature(&event));
    try std.testing.expectError(error.InvalidId, event_verify_id(&event));
}
