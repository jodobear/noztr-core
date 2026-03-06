const std = @import("std");
const secp256k1 = @import("secp256k1");

/// Typed boundary errors for the secp256k1 verification path.
pub const BackendVerifyError = error{
    InvalidPublicKey,
    InvalidSignature,
    BackendUnavailable,
};

var verify_signature_call_count: u32 = 0;

pub fn reset_counters() void {
    std.debug.assert(verify_signature_call_count >= 0);
    std.debug.assert(!@inComptime());

    verify_signature_call_count = 0;
    std.debug.assert(verify_signature_call_count == 0);
}

pub fn get_verify_signature_call_count() u32 {
    std.debug.assert(verify_signature_call_count >= 0);
    std.debug.assert(!@inComptime());

    return verify_signature_call_count;
}

pub fn verify_schnorr_signature(
    public_key: *const [32]u8,
    message_digest: *const [32]u8,
    signature: *const [64]u8,
) BackendVerifyError!void {
    std.debug.assert(public_key[0] <= 255);
    std.debug.assert(signature[0] <= 255);

    verify_signature_call_count += 1;

    const parsed_public_key = secp256k1.XOnlyPublicKey.from_slice(public_key) catch |verify_error| {
        return map_public_key_error(verify_error);
    };
    secp256k1.verify_schnorr(&parsed_public_key, message_digest, signature) catch |verify_error| {
        return map_signature_error(verify_error);
    };
}

fn map_public_key_error(verify_error: secp256k1.Error) BackendVerifyError {
    std.debug.assert(@intFromError(verify_error) >= 0);
    std.debug.assert(!@inComptime());

    return switch (verify_error) {
        error.InvalidPublicKey => error.InvalidPublicKey,
        else => error.BackendUnavailable,
    };
}

fn map_signature_error(verify_error: secp256k1.Error) BackendVerifyError {
    std.debug.assert(@intFromError(verify_error) >= 0);
    std.debug.assert(!@inComptime());

    return switch (verify_error) {
        error.InvalidSignature => error.InvalidSignature,
        else => error.BackendUnavailable,
    };
}

test "boundary verify counter and typed failures are deterministic" {
    var valid_public_key: [32]u8 = undefined;
    var valid_signature: [64]u8 = undefined;
    const message_digest: [32]u8 = [_]u8{0} ** 32;
    var invalid_public_key: [32]u8 = undefined;

    _ = try std.fmt.hexToBytes(
        &valid_public_key,
        "F9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9",
    );
    _ = try std.fmt.hexToBytes(
        &valid_signature,
        "E907831F80848D1069A5371B402410364BDF1C5F8307B0084C55F1CE2DCA8215" ++
            "25F66A4A85EA8B71E482A74F382D2CE5EBEEE8FDB2172F477DF4900D310536C0",
    );
    _ = try std.fmt.hexToBytes(
        &invalid_public_key,
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC30",
    );

    reset_counters();
    try verify_schnorr_signature(&valid_public_key, &message_digest, &valid_signature);
    try std.testing.expect(get_verify_signature_call_count() == 1);

    valid_signature[0] ^= 1;
    try std.testing.expectError(
        error.InvalidSignature,
        verify_schnorr_signature(&valid_public_key, &message_digest, &valid_signature),
    );

    try std.testing.expectError(
        error.InvalidPublicKey,
        verify_schnorr_signature(&invalid_public_key, &message_digest, &valid_signature),
    );

    try std.testing.expect(get_verify_signature_call_count() == 3);
}
