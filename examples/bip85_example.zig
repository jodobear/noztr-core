const std = @import("std");
const noztr = @import("noztr");

test "BIP-85 example: derive bounded hex entropy and child mnemonic" {
    const mnemonic =
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage";
    var hex_output: [64]u8 = undefined;
    var output: [noztr.limits.bip85_mnemonic_bytes_max]u8 = undefined;
    const child_hex = try noztr.bip85_derivation.derive_hex_entropy(
        hex_output[0..],
        mnemonic,
        null,
        16,
        0,
    );

    const child = try noztr.bip85_derivation.derive_bip39_mnemonic(
        output[0..],
        mnemonic,
        null,
        .words_12,
        0,
    );

    try std.testing.expectEqual(
        @as(usize, 12),
        std.mem.count(u8, child, " ") + 1,
    );
    try std.testing.expectEqual(@as(usize, 32), child_hex.len);
    try std.testing.expect(std.ascii.isHex(child_hex[0]));
    try std.testing.expect(child.len > 0);
}
