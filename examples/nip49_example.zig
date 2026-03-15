const std = @import("std");
const noztr = @import("noztr");

test "NIP-49 example: encrypt and decrypt one secret key as ncryptsec" {
    const secret_key = [_]u8{0x11} ** 32;
    const salt = [_]u8{0x22} ** 16;
    const nonce = [_]u8{0x33} ** 24;
    var scratch: [19_501]u8 = undefined;
    var encoded: [noztr.limits.nip49_bech32_bytes_max]u8 = undefined;
    var decrypted: [32]u8 = undefined;

    const encrypted = try noztr.nip49_private_key_encryption.nip49_encrypt_with_salt_and_nonce(
        &secret_key,
        "ÅΩẛ̣",
        4,
        .medium,
        scratch[0..],
        &salt,
        &nonce,
    );
    const cryptsec = try noztr.nip49_private_key_encryption.nip49_encode_bech32(
        encoded[0..],
        encrypted,
    );
    const decoded = try noztr.nip49_private_key_encryption.nip49_decode_bech32(cryptsec);
    try noztr.nip49_private_key_encryption.nip49_decrypt(
        &decrypted,
        decoded,
        "ÅΩṩ",
        scratch[0..],
    );

    try std.testing.expectEqual(@as(u64, 19_501), try noztr.nip49_private_key_encryption.nip49_scrypt_scratch_bytes(4));
    try std.testing.expectEqual(noztr.nip49_private_key_encryption.KeySecurity.medium, decoded.key_security);
    try std.testing.expectEqualStrings("ncryptsec", cryptsec[0..9]);
    try std.testing.expectEqualSlices(u8, secret_key[0..], decrypted[0..]);
}
