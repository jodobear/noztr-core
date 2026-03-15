const std = @import("std");
const noztr = @import("noztr");

test "recipe: deterministic wallet flows use nip06 plus bip85 directly" {
    const mnemonic =
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage";
    var seed_output: [noztr.limits.nip06_seed_bytes]u8 = undefined;
    var secret_output: [32]u8 = undefined;
    var hex_output: [32]u8 = undefined;
    var child_mnemonic_output: [noztr.limits.bip85_mnemonic_bytes_max]u8 = undefined;

    const seed = try noztr.nip06_mnemonic.mnemonic_to_seed(seed_output[0..], mnemonic, null);
    const secret_key = try noztr.nip06_mnemonic.derive_nostr_secret_key(
        secret_output[0..],
        mnemonic,
        null,
        0,
    );
    const child_hex = try noztr.bip85_derivation.derive_hex_entropy_from_seed(
        hex_output[0..],
        seed,
        16,
        0,
    );
    const child_mnemonic = try noztr.bip85_derivation.derive_bip39_mnemonic(
        child_mnemonic_output[0..],
        mnemonic,
        null,
        .words_12,
        0,
    );

    try std.testing.expectEqual(@as(usize, 64), seed.len);
    try std.testing.expectEqual(@as(usize, 32), secret_key.len);
    try std.testing.expectEqual(@as(usize, 16), child_hex.len);
    try std.testing.expectEqualStrings(
        "girl mad pet galaxy egg matter matrix prison refuse sense ordinary nose",
        child_mnemonic,
    );
}
