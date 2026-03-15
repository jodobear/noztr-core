const std = @import("std");
const noztr = @import("noztr");

test "NIP-49 adversarial example: wrong passwords and invalid log_n stay typed" {
    const secret_key = [_]u8{0x44} ** 32;
    const salt = [_]u8{0x55} ** 16;
    const nonce = [_]u8{0x66} ** 24;
    var scratch: [19_501]u8 = undefined;
    var encoded: [noztr.limits.nip49_bech32_bytes_max]u8 = undefined;
    var decrypted: [32]u8 = undefined;

    const cryptsec = try noztr.nip49_private_key_encryption.nip49_encrypt_with_salt_and_nonce_to_bech32(
        encoded[0..],
        &secret_key,
        "nostr",
        4,
        .unknown,
        scratch[0..],
        &salt,
        &nonce,
    );

    try std.testing.expectError(
        error.InvalidCiphertext,
        noztr.nip49_private_key_encryption.nip49_decrypt_from_bech32(
            &decrypted,
            cryptsec,
            "wrong-password",
            scratch[0..],
        ),
    );
    try std.testing.expectError(
        error.InvalidLogN,
        noztr.nip49_private_key_encryption.nip49_encrypt_with_salt_and_nonce_to_bech32(
            encoded[0..],
            &secret_key,
            "nostr",
            0,
            .unknown,
            scratch[0..],
            &salt,
            &nonce,
        ),
    );
}
