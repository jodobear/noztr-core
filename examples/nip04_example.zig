const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-04 example: local encrypt and decrypt with fixed IV" {
    const sender_secret = [_]u8{0x11} ** 32;
    const recipient_secret = [_]u8{0x22} ** 32;
    const recipient_pubkey = try common.derive_public_key(&recipient_secret);
    const sender_pubkey = try common.derive_public_key(&sender_secret);
    const iv = [_]u8{0x44} ** noztr.limits.nip04_iv_bytes;

    var payload_storage: [noztr.limits.content_bytes_max]u8 = undefined;
    const payload = try noztr.nip04.nip04_encrypt_with_iv(
        payload_storage[0..],
        &sender_secret,
        &recipient_pubkey,
        "legacy dm",
        &iv,
    );
    var plaintext: [noztr.limits.nip04_plaintext_max_bytes]u8 = undefined;
    const decrypted = try noztr.nip04.nip04_decrypt(
        plaintext[0..],
        &recipient_secret,
        &sender_pubkey,
        payload,
    );

    try std.testing.expectEqualStrings("legacy dm", decrypted);
}
