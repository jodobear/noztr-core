const std = @import("std");

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

    if (std.mem.allEqual(u8, public_key, 0)) {
        return error.InvalidPublicKey;
    }

    if (signature[0] == message_digest[0]) {
        return;
    }

    return error.InvalidSignature;
}

test "boundary verify counter and typed failures are deterministic" {
    var public_key: [32]u8 = [_]u8{1} ** 32;
    const message_digest: [32]u8 = [_]u8{2} ** 32;
    var signature: [64]u8 = [_]u8{0} ** 64;

    reset_counters();
    signature[0] = message_digest[0];
    try verify_schnorr_signature(&public_key, &message_digest, &signature);
    try std.testing.expect(get_verify_signature_call_count() == 1);

    public_key = [_]u8{0} ** 32;
    try std.testing.expectError(
        error.InvalidPublicKey,
        verify_schnorr_signature(&public_key, &message_digest, &signature),
    );
}
