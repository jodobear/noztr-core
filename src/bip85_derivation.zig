const std = @import("std");
const limits = @import("limits.zig");
const nip06_mnemonic = @import("nip06_mnemonic.zig");
const libwally = @import("libwally");

const HmacSha512 = std.crypto.auth.hmac.sha2.HmacSha512;
const c = libwally.c;
const hardened_bit: u32 = c.BIP32_INITIAL_HARDENED_CHILD;
const entropy_hmac_key = "bip-entropy-from-k";
const private_skip_hash: u32 = c.BIP32_FLAG_KEY_PRIVATE | c.BIP32_FLAG_SKIP_HASH;
const bip85_root: u32 = hardened_bit | 83_696_968;
const bip39_app: u32 = hardened_bit | 39;
const hex_app: u32 = hardened_bit | 128_169;
const english_language: u32 = hardened_bit;

pub const Bip85Error = error{
    InvalidMnemonicLength,
    UnknownMnemonicWord,
    InvalidChecksum,
    InvalidUtf8,
    InvalidNormalization,
    InvalidSeed,
    InvalidAccount,
    InvalidIndex,
    InvalidByteLength,
    InvalidWordCount,
    DerivationFailure,
    BufferTooSmall,
    BackendUnavailable,
};

pub const Bip39WordCount = enum(u8) {
    words_12 = 12,
    words_15 = 15,
    words_18 = 18,
    words_21 = 21,
    words_24 = 24,
};

/// Derive bounded BIP-85 hex entropy from a BIP39 seed.
/// See `examples/bip85_example.zig` and `examples/wallet_recipe.zig`.
pub fn derive_hex_entropy_from_seed(
    output: []u8,
    seed: []const u8,
    bytes_len: u8,
    index: u32,
) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(seed.len <= limits.nip06_seed_bytes);

    if (seed.len != limits.nip06_seed_bytes) return error.InvalidSeed;
    if (bytes_len < 16 or bytes_len > 64) return error.InvalidByteLength;
    try ensure_valid_index(index);

    var derived = try derive_entropy_material(seed, &.{
        bip85_root,
        hex_app,
        hardened_bit | bytes_len,
        hardened_bit | index,
    });
    defer wipe_bytes(derived[0..]);

    if (output.len < bytes_len) return error.BufferTooSmall;
    @memcpy(output[0..bytes_len], derived[0..bytes_len]);
    return output[0..bytes_len];
}

/// Derive bounded BIP-85 hex entropy from a validated English mnemonic.
pub fn derive_hex_entropy(
    output: []u8,
    mnemonic: []const u8,
    passphrase: ?[]const u8,
    bytes_len: u8,
    index: u32,
) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(mnemonic.len <= limits.nip06_mnemonic_bytes_max);

    var seed: [limits.nip06_seed_bytes]u8 = undefined;
    defer wipe_bytes(seed[0..]);
    _ = try nip06_mnemonic.mnemonic_to_seed(seed[0..], mnemonic, passphrase);
    return derive_hex_entropy_from_seed(output, seed[0..], bytes_len, index);
}

/// Derive English BIP39 child entropy from a BIP39 seed.
pub fn derive_bip39_entropy_from_seed(
    output: []u8,
    seed: []const u8,
    word_count: Bip39WordCount,
    index: u32,
) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(seed.len <= limits.nip06_seed_bytes);

    if (seed.len != limits.nip06_seed_bytes) return error.InvalidSeed;
    try ensure_valid_index(index);

    const entropy_len = word_count_entropy_len(word_count);
    var derived = try derive_entropy_material(seed, &.{
        bip85_root,
        bip39_app,
        english_language,
        hardened_bit | @intFromEnum(word_count),
        hardened_bit | index,
    });
    defer wipe_bytes(derived[0..]);

    if (output.len < entropy_len) return error.BufferTooSmall;
    @memcpy(output[0..entropy_len], derived[0..entropy_len]);
    return output[0..entropy_len];
}

/// Derive an English BIP39 child mnemonic directly from a BIP39 seed.
pub fn derive_bip39_mnemonic_from_seed(
    output: []u8,
    seed: []const u8,
    word_count: Bip39WordCount,
    index: u32,
) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(seed.len <= limits.nip06_seed_bytes);

    var entropy: [32]u8 = undefined;
    defer wipe_bytes(entropy[0..]);
    const entropy_slice = try derive_bip39_entropy_from_seed(
        entropy[0..],
        seed,
        word_count,
        index,
    );
    return write_mnemonic_from_entropy(output, entropy_slice);
}

/// Derive English BIP39 child entropy from a validated English mnemonic.
pub fn derive_bip39_entropy(
    output: []u8,
    mnemonic: []const u8,
    passphrase: ?[]const u8,
    word_count: Bip39WordCount,
    index: u32,
) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(mnemonic.len <= limits.nip06_mnemonic_bytes_max);

    var seed: [limits.nip06_seed_bytes]u8 = undefined;
    defer wipe_bytes(seed[0..]);
    _ = try nip06_mnemonic.mnemonic_to_seed(seed[0..], mnemonic, passphrase);
    return derive_bip39_entropy_from_seed(output, seed[0..], word_count, index);
}

/// Derive an English BIP39 child mnemonic from a validated English mnemonic.
/// See `examples/bip85_example.zig` and `examples/wallet_recipe.zig`.
pub fn derive_bip39_mnemonic(
    output: []u8,
    mnemonic: []const u8,
    passphrase: ?[]const u8,
    word_count: Bip39WordCount,
    index: u32,
) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(mnemonic.len <= limits.nip06_mnemonic_bytes_max);

    var seed: [limits.nip06_seed_bytes]u8 = undefined;
    defer wipe_bytes(seed[0..]);
    _ = try nip06_mnemonic.mnemonic_to_seed(seed[0..], mnemonic, passphrase);
    return derive_bip39_mnemonic_from_seed(output, seed[0..], word_count, index);
}

fn ensure_valid_index(index: u32) Bip85Error!void {
    std.debug.assert(@sizeOf(u32) == 4);

    if (index >= hardened_bit) return error.InvalidIndex;
}

fn word_count_entropy_len(word_count: Bip39WordCount) u8 {
    std.debug.assert(@sizeOf(Bip39WordCount) == 1);
    std.debug.assert(@intFromEnum(word_count) >= 12);

    return switch (word_count) {
        .words_12 => 16,
        .words_15 => 20,
        .words_18 => 24,
        .words_21 => 28,
        .words_24 => 32,
    };
}

fn derive_entropy_material(seed: []const u8, path: []const u32) Bip85Error![64]u8 {
    std.debug.assert(seed.len == limits.nip06_seed_bytes);
    std.debug.assert(path.len > 0);

    try ensure_backend();

    var master_key: c.struct_ext_key = undefined;
    defer wipe_ext_key(&master_key);
    try create_master_key(seed, &master_key);

    var derived_key: c.struct_ext_key = undefined;
    defer wipe_ext_key(&derived_key);
    try derive_hardened_path(&master_key, path, &derived_key);

    return hmac_entropy_from_key(&derived_key);
}

fn ensure_backend() Bip85Error!void {
    std.debug.assert(@sizeOf(Bip85Error) > 0);
    std.debug.assert(!@inComptime());

    nip06_mnemonic.mnemonic_validate(
        "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
    ) catch |err| switch (err) {
        error.InvalidChecksum => return,
        error.BackendUnavailable => return error.BackendUnavailable,
        else => return error.BackendUnavailable,
    };
}

fn create_master_key(seed: []const u8, output: *c.struct_ext_key) Bip85Error!void {
    std.debug.assert(seed.len == limits.nip06_seed_bytes);
    std.debug.assert(@sizeOf(c.struct_ext_key) > limits.nip06_seed_bytes);

    const result = c.bip32_key_from_seed(
        seed.ptr,
        seed.len,
        c.BIP32_VER_MAIN_PRIVATE,
        c.BIP32_FLAG_SKIP_HASH,
        output,
    );
    if (result != c.WALLY_OK) return error.DerivationFailure;
}

fn derive_hardened_path(
    parent: *const c.struct_ext_key,
    path: []const u32,
    output: *c.struct_ext_key,
) Bip85Error!void {
    std.debug.assert(path.len > 0);
    std.debug.assert(path.len <= 5);

    const result = c.bip32_key_from_parent_path(
        parent,
        path.ptr,
        path.len,
        private_skip_hash,
        output,
    );
    if (result != c.WALLY_OK) return error.DerivationFailure;
}

fn hmac_entropy_from_key(hdkey: *const c.struct_ext_key) [64]u8 {
    std.debug.assert(hdkey.priv_key.len == limits.nip06_secret_key_bytes + 1);
    std.debug.assert(hdkey.priv_key[0] == 0);

    var output: [64]u8 = undefined;
    var hmac = HmacSha512.init(entropy_hmac_key);
    hmac.update(hdkey.priv_key[1 .. limits.nip06_secret_key_bytes + 1]);
    hmac.final(&output);
    return output;
}

fn write_mnemonic_from_entropy(output: []u8, entropy: []const u8) Bip85Error![]const u8 {
    std.debug.assert(output.len <= limits.content_bytes_max);
    std.debug.assert(entropy.len >= 16 and entropy.len <= 32);

    var mnemonic_c: [*c]u8 = null;
    const result = c.bip39_mnemonic_from_bytes(null, entropy.ptr, entropy.len, &mnemonic_c);
    if (result != c.WALLY_OK or mnemonic_c == null) return error.DerivationFailure;
    defer free_mnemonic_c_string(mnemonic_c);

    const mnemonic = std.mem.span(mnemonic_c);
    if (mnemonic.len > output.len) return error.BufferTooSmall;
    @memcpy(output[0..mnemonic.len], mnemonic);
    return output[0..mnemonic.len];
}

fn free_mnemonic_c_string(text: [*c]u8) void {
    std.debug.assert(text != null);
    std.debug.assert(!@inComptime());

    const slice = std.mem.span(text);
    _ = c.wally_bzero(@ptrCast(text), slice.len + 1);
    _ = c.wally_free_string(text);
}

fn wipe_ext_key(hdkey: *c.struct_ext_key) void {
    std.debug.assert(!@inComptime());
    std.debug.assert(@sizeOf(c.struct_ext_key) > 0);

    wipe_bytes(std.mem.asBytes(hdkey));
}

fn wipe_bytes(bytes: []u8) void {
    std.debug.assert(bytes.len >= 0);
    std.debug.assert(!@inComptime());

    std.crypto.secureZero(u8, bytes);
}

test "derive english bip39 child vector from mnemonic" {
    var mnemonic_output: [limits.nip06_mnemonic_bytes_max]u8 = undefined;
    const actual_mnemonic = try derive_bip39_mnemonic(
        mnemonic_output[0..],
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage",
        null,
        .words_12,
        0,
    );
    try std.testing.expectEqualStrings(
        "girl mad pet galaxy egg matter matrix prison refuse sense ordinary nose",
        actual_mnemonic,
    );
}

test "derive english bip39 child entropy vector from mnemonic" {
    var entropy_output: [32]u8 = undefined;
    const actual = try derive_bip39_entropy(
        entropy_output[0..],
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage",
        null,
        .words_12,
        0,
    );
    try expect_hex("6250b68daf746d12a24d58b4787a714b", actual);
}

test "derive hex entropy vector from mnemonic" {
    var entropy_output: [64]u8 = undefined;
    const actual = try derive_hex_entropy(
        entropy_output[0..],
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage",
        null,
        64,
        0,
    );
    try expect_hex(
        "492db4698cf3b73a5a24998aa3e9d7fa96275d85724a91e71aa2d645442f8785" ++
            "55d078fd1f1f67e368976f04137b1f7a0d19232136ca50c44614af72b5582a5c",
        actual,
    );
}

test "derive bip39 child helpers support all standard word counts" {
    const parent =
        "install scatter logic circle pencil average fall shoe quantum disease suspect usage";
    const counts = [_]Bip39WordCount{ .words_12, .words_15, .words_18, .words_21, .words_24 };
    var previous: [limits.nip06_mnemonic_bytes_max]u8 = undefined;
    var previous_len: usize = 0;

    for (counts) |count| {
        var current: [limits.nip06_mnemonic_bytes_max]u8 = undefined;
        const child = try derive_bip39_mnemonic(current[0..], parent, null, count, 0);
        try nip06_mnemonic.mnemonic_validate(child);
        try expect_word_count(child, @intFromEnum(count));
        if (previous_len != 0) try std.testing.expect(!std.mem.eql(u8, previous[0..previous_len], child));
        @memcpy(previous[0..child.len], child);
        previous_len = child.len;
    }
}

test "derive entropy helpers reject invalid boundaries" {
    var output: [64]u8 = undefined;
    var short_seed: [32]u8 = [_]u8{0} ** 32;

    try std.testing.expectError(
        error.InvalidByteLength,
        derive_hex_entropy(output[0..], "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", null, 15, 0),
    );
    try std.testing.expectError(
        error.InvalidIndex,
        derive_hex_entropy(output[0..], "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about", null, 16, hardened_bit),
    );
    try std.testing.expectError(
        error.InvalidSeed,
        derive_hex_entropy_from_seed(output[0..], short_seed[0..], 16, 0),
    );
}

fn expect_hex(expected_hex: []const u8, actual: []const u8) !void {
    std.debug.assert(expected_hex.len == actual.len * 2);
    std.debug.assert(actual.len > 0);

    var expected: [64]u8 = undefined;
    const decoded = try std.fmt.hexToBytes(expected[0..], expected_hex);
    try std.testing.expectEqualSlices(u8, decoded, actual);
}

fn expect_word_count(mnemonic: []const u8, expected_count: u8) !void {
    std.debug.assert(expected_count >= 12);
    std.debug.assert(expected_count <= 24);

    var count: u8 = 1;
    for (mnemonic) |byte| {
        if (byte == ' ') count += 1;
    }
    try std.testing.expectEqual(expected_count, count);
}
