const std = @import("std");
const internal_bech32 = @import("internal/bech32.zig");
const limits = @import("limits.zig");
const nostr_keys = @import("nostr_keys.zig");
const unicode_nfkc = @import("unicode_nfkc.zig");

const XChaCha20Poly1305 = std.crypto.aead.chacha_poly.XChaCha20Poly1305;
const scrypt = std.crypto.pwhash.scrypt;
pub const ncryptsec_hrp = "ncryptsec";
pub const version_v2: u8 = limits.nip49_version;

const max_log_n: u8 = 22;
const alignment_slop_bytes: u8 = 45;
const ciphertext_body_bytes: u8 = limits.nip49_key_bytes;
pub const PrivateKeyEncryptionError = error{
    InvalidUtf8,
    InvalidNormalization,
    InvalidSecretKey,
    BackendUnavailable,
    InvalidBech32,
    InvalidChecksum,
    MixedCase,
    InvalidPrefix,
    InvalidPayload,
    InvalidVersion,
    InvalidLogN,
    InvalidKeySecurity,
    InvalidCiphertext,
    BufferTooSmall,
};

pub const KeySecurity = enum(u8) {
    weak = 0x00,
    medium = 0x01,
    unknown = 0x02,
};

pub const EncryptedSecretKey = struct {
    version: u8 = version_v2,
    log_n: u8,
    salt: [limits.nip49_salt_bytes]u8,
    nonce: [limits.nip49_nonce_bytes]u8,
    key_security: KeySecurity,
    ciphertext: [limits.nip49_ciphertext_bytes]u8,
};

/// Return the minimum caller-owned scratch bytes required for the fixed NIP-49 scrypt boundary.
pub fn nip49_scrypt_scratch_bytes(log_n: u8) PrivateKeyEncryptionError!u64 {
    try validate_log_n(log_n);

    const rounds = @as(u64, 1) << @intCast(log_n);
    const r = @as(u64, limits.nip49_scrypt_r);
    const p = @as(u64, limits.nip49_scrypt_p);
    const xy_bytes = @as(u64, 64) * r * @sizeOf(u32);
    const v_bytes = @as(u64, 32) * rounds * r * @sizeOf(u32);
    const dk_bytes = p * 128 * r;
    return xy_bytes + v_bytes + dk_bytes + alignment_slop_bytes;
}

/// Parse the fixed 91-byte NIP-49 payload into a typed frame.
pub fn nip49_parse_bytes(input: []const u8) PrivateKeyEncryptionError!EncryptedSecretKey {
    std.debug.assert(limits.nip49_payload_bytes == 91);
    std.debug.assert(43 + limits.nip49_ciphertext_bytes == limits.nip49_payload_bytes);

    if (input.len != limits.nip49_payload_bytes) return error.InvalidPayload;

    const version = input[0];
    const log_n = input[1];
    const key_security = try parse_key_security(input[42]);
    if (version != version_v2) return error.InvalidVersion;
    try validate_log_n(log_n);

    var salt: [limits.nip49_salt_bytes]u8 = undefined;
    var nonce: [limits.nip49_nonce_bytes]u8 = undefined;
    var ciphertext: [limits.nip49_ciphertext_bytes]u8 = undefined;
    @memcpy(salt[0..], input[2..18]);
    @memcpy(nonce[0..], input[18..42]);
    @memcpy(ciphertext[0..], input[43..91]);
    return .{
        .version = version,
        .log_n = log_n,
        .salt = salt,
        .nonce = nonce,
        .key_security = key_security,
        .ciphertext = ciphertext,
    };
}

/// Serialize a validated NIP-49 frame into its fixed 91-byte payload.
pub fn nip49_serialize_bytes(
    output: []u8,
    encrypted: EncryptedSecretKey,
) PrivateKeyEncryptionError![]const u8 {
    std.debug.assert(limits.nip49_payload_bytes == 91);
    std.debug.assert(43 + limits.nip49_ciphertext_bytes == limits.nip49_payload_bytes);

    if (output.len < limits.nip49_payload_bytes) return error.BufferTooSmall;
    try validate_frame(encrypted);

    output[0] = encrypted.version;
    output[1] = encrypted.log_n;
    @memcpy(output[2..18], encrypted.salt[0..]);
    @memcpy(output[18..42], encrypted.nonce[0..]);
    output[42] = @intFromEnum(encrypted.key_security);
    @memcpy(output[43..91], encrypted.ciphertext[0..]);
    return output[0..limits.nip49_payload_bytes];
}

/// Decode a bech32 `ncryptsec` string into a typed NIP-49 frame.
pub fn nip49_decode_bech32(input: []const u8) PrivateKeyEncryptionError!EncryptedSecretKey {
    std.debug.assert(ncryptsec_hrp.len > 0);
    std.debug.assert(limits.nip49_payload_bytes <= limits.nip49_bech32_bytes_max);

    var hrp_buffer: [ncryptsec_hrp.len]u8 = undefined;
    var value_buffer: [limits.nip49_bech32_bytes_max]u8 = undefined;
    const decoded = internal_bech32.decode(input, hrp_buffer[0..], value_buffer[0..]) catch |err| {
        return map_bech32_error(err);
    };
    if (!std.mem.eql(u8, decoded.hrp, ncryptsec_hrp)) return error.InvalidPrefix;

    var payload: [limits.nip49_payload_bytes]u8 = undefined;
    const payload_len = internal_bech32.convert_bits(payload[0..], decoded.payload_values, 5, 8, false) catch |err| {
        return switch (err) {
            error.InvalidPayload => error.InvalidPayload,
            error.BufferTooSmall => error.InvalidPayload,
            error.InvalidBech32,
            error.InvalidChecksum,
            error.MixedCase,
            error.ValueOutOfRange,
            => error.InvalidPayload,
        };
    };
    if (payload_len != limits.nip49_payload_bytes) return error.InvalidPayload;
    return nip49_parse_bytes(payload[0..payload_len]);
}

/// Encode a typed NIP-49 frame into its canonical lowercase bech32 `ncryptsec` form.
pub fn nip49_encode_bech32(
    output: []u8,
    encrypted: EncryptedSecretKey,
) PrivateKeyEncryptionError![]const u8 {
    std.debug.assert(ncryptsec_hrp.len > 0);
    std.debug.assert(limits.nip49_payload_bytes <= limits.nip49_bech32_bytes_max);

    var payload: [limits.nip49_payload_bytes]u8 = undefined;
    var data_values: [limits.nip49_bech32_bytes_max]u8 = undefined;
    const serialized = try nip49_serialize_bytes(payload[0..], encrypted);
    return internal_bech32.encode(output, ncryptsec_hrp, serialized, data_values[0..]) catch |err| {
        return map_bech32_error(err);
    };
}

/// Encrypt a validated secret key with random salt and nonce and return the typed frame.
pub fn nip49_encrypt(
    secret_key: *const [limits.nip49_key_bytes]u8,
    password: []const u8,
    log_n: u8,
    key_security: KeySecurity,
    scrypt_scratch: []u8,
) PrivateKeyEncryptionError!EncryptedSecretKey {
    std.debug.assert(@intFromPtr(secret_key) != 0);
    std.debug.assert(limits.nip49_key_bytes == 32);

    var salt: [limits.nip49_salt_bytes]u8 = undefined;
    var nonce: [limits.nip49_nonce_bytes]u8 = undefined;
    std.crypto.random.bytes(salt[0..]);
    std.crypto.random.bytes(nonce[0..]);
    return nip49_encrypt_with_salt_and_nonce(
        secret_key,
        password,
        log_n,
        key_security,
        scrypt_scratch,
        &salt,
        &nonce,
    );
}

/// Encrypt a validated secret key with caller-supplied salt and nonce and return the typed frame.
pub fn nip49_encrypt_with_salt_and_nonce(
    secret_key: *const [limits.nip49_key_bytes]u8,
    password: []const u8,
    log_n: u8,
    key_security: KeySecurity,
    scrypt_scratch: []u8,
    salt: *const [limits.nip49_salt_bytes]u8,
    nonce: *const [limits.nip49_nonce_bytes]u8,
) PrivateKeyEncryptionError!EncryptedSecretKey {
    std.debug.assert(@intFromPtr(secret_key) != 0);
    std.debug.assert(@intFromPtr(salt) != 0);
    std.debug.assert(@intFromPtr(nonce) != 0);
    std.debug.assert(limits.nip49_key_bytes == 32);

    _ = nostr_keys.nostr_derive_public_key(secret_key) catch |err| return map_key_error(err);

    var key: [limits.nip49_key_bytes]u8 = undefined;
    defer wipe_bytes(key[0..]);
    try derive_key(&key, scrypt_scratch, password, salt, log_n);

    return .{
        .version = version_v2,
        .log_n = log_n,
        .salt = salt.*,
        .nonce = nonce.*,
        .key_security = key_security,
        .ciphertext = encrypt_ciphertext(secret_key, key_security, nonce, &key),
    };
}

/// Encrypt to the canonical lowercase bech32 `ncryptsec` form with random salt and nonce.
pub fn nip49_encrypt_to_bech32(
    output: []u8,
    secret_key: *const [limits.nip49_key_bytes]u8,
    password: []const u8,
    log_n: u8,
    key_security: KeySecurity,
    scrypt_scratch: []u8,
) PrivateKeyEncryptionError![]const u8 {
    const encrypted = try nip49_encrypt(secret_key, password, log_n, key_security, scrypt_scratch);
    return nip49_encode_bech32(output, encrypted);
}

/// Encrypt to bech32 with caller-supplied salt and nonce for deterministic vectors and parity tests.
pub fn nip49_encrypt_with_salt_and_nonce_to_bech32(
    output: []u8,
    secret_key: *const [limits.nip49_key_bytes]u8,
    password: []const u8,
    log_n: u8,
    key_security: KeySecurity,
    scrypt_scratch: []u8,
    salt: *const [limits.nip49_salt_bytes]u8,
    nonce: *const [limits.nip49_nonce_bytes]u8,
) PrivateKeyEncryptionError![]const u8 {
    const encrypted = try nip49_encrypt_with_salt_and_nonce(
        secret_key,
        password,
        log_n,
        key_security,
        scrypt_scratch,
        salt,
        nonce,
    );
    return nip49_encode_bech32(output, encrypted);
}

/// Decrypt a typed NIP-49 frame into one validated secp256k1 secret key.
pub fn nip49_decrypt(
    output_secret_key: *[limits.nip49_key_bytes]u8,
    encrypted: EncryptedSecretKey,
    password: []const u8,
    scrypt_scratch: []u8,
) PrivateKeyEncryptionError!void {
    std.debug.assert(@intFromPtr(output_secret_key) != 0);
    std.debug.assert(limits.nip49_key_bytes == 32);

    errdefer wipe_bytes(output_secret_key[0..]);
    try validate_frame(encrypted);

    var key: [limits.nip49_key_bytes]u8 = undefined;
    defer wipe_bytes(key[0..]);
    try derive_key(&key, scrypt_scratch, password, &encrypted.salt, encrypted.log_n);
    try decrypt_ciphertext(output_secret_key, encrypted, &key);
    _ = nostr_keys.nostr_derive_public_key(output_secret_key) catch |err| return map_key_error(err);
}

/// Decode and decrypt one canonical `ncryptsec` string into a validated secp256k1 secret key.
pub fn nip49_decrypt_from_bech32(
    output_secret_key: *[limits.nip49_key_bytes]u8,
    input: []const u8,
    password: []const u8,
    scrypt_scratch: []u8,
) PrivateKeyEncryptionError!void {
    std.debug.assert(@intFromPtr(output_secret_key) != 0);
    std.debug.assert(ncryptsec_hrp.len > 0);

    const encrypted = try nip49_decode_bech32(input);
    try nip49_decrypt(output_secret_key, encrypted, password, scrypt_scratch);
}

fn derive_key(
    output_key: *[limits.nip49_key_bytes]u8,
    scrypt_scratch: []u8,
    password: []const u8,
    salt: *const [limits.nip49_salt_bytes]u8,
    log_n: u8,
) PrivateKeyEncryptionError!void {
    try validate_log_n(log_n);
    try require_scrypt_scratch(scrypt_scratch, log_n);

    var normalized_storage: [limits.nip49_password_normalized_bytes_max]u8 = undefined;
    defer wipe_bytes(normalized_storage[0..]);
    const normalized = try normalize_password(normalized_storage[0..], password);

    var fba = std.heap.FixedBufferAllocator.init(scrypt_scratch);
    defer wipe_bytes(scrypt_scratch[0..fba.end_index]);
    const params = scrypt.Params{
        .ln = @intCast(log_n),
        .r = limits.nip49_scrypt_r,
        .p = limits.nip49_scrypt_p,
    };
    scrypt.kdf(fba.allocator(), output_key[0..], normalized, salt[0..], params) catch |err| {
        return switch (err) {
            error.WeakParameters => error.InvalidLogN,
            error.OutOfMemory => error.BufferTooSmall,
            else => unreachable,
        };
    };
}

fn normalize_password(output: []u8, password: []const u8) PrivateKeyEncryptionError![]const u8 {
    std.debug.assert(output.len >= limits.nip49_password_normalized_bytes_max);
    std.debug.assert(password.len <= limits.content_bytes_max);

    if (password.len > limits.nip49_password_bytes_max) return error.InvalidNormalization;
    return unicode_nfkc.normalize(output, password) catch |err| switch (err) {
        error.InvalidUtf8 => error.InvalidUtf8,
        error.BufferTooSmall => error.InvalidNormalization,
        error.InvalidNormalization => error.InvalidNormalization,
    };
}

fn require_scrypt_scratch(scrypt_scratch: []const u8, log_n: u8) PrivateKeyEncryptionError!void {
    const required = try nip49_scrypt_scratch_bytes(log_n);
    if (required > std.math.maxInt(usize)) return error.InvalidLogN;
    if (@as(u64, scrypt_scratch.len) < required) return error.BufferTooSmall;
}

fn validate_log_n(log_n: u8) PrivateKeyEncryptionError!void {
    if (log_n == 0) return error.InvalidLogN;
    if (log_n > max_log_n) return error.InvalidLogN;
}

fn validate_frame(encrypted: EncryptedSecretKey) PrivateKeyEncryptionError!void {
    if (encrypted.version != version_v2) return error.InvalidVersion;
    try validate_log_n(encrypted.log_n);
    _ = parse_key_security(@intFromEnum(encrypted.key_security)) catch return error.InvalidKeySecurity;
}

fn parse_key_security(value: u8) PrivateKeyEncryptionError!KeySecurity {
    return switch (value) {
        0x00 => .weak,
        0x01 => .medium,
        0x02 => .unknown,
        else => error.InvalidKeySecurity,
    };
}

fn encrypt_ciphertext(
    secret_key: *const [limits.nip49_key_bytes]u8,
    key_security: KeySecurity,
    nonce: *const [limits.nip49_nonce_bytes]u8,
    key: *const [limits.nip49_key_bytes]u8,
) [limits.nip49_ciphertext_bytes]u8 {
    var ciphertext: [limits.nip49_ciphertext_bytes]u8 = undefined;
    const aad = [_]u8{@intFromEnum(key_security)};
    XChaCha20Poly1305.encrypt(
        ciphertext[0..ciphertext_body_bytes],
        ciphertext[ciphertext_body_bytes..],
        secret_key[0..],
        aad[0..],
        nonce.*,
        key.*,
    );
    return ciphertext;
}

fn decrypt_ciphertext(
    output_secret_key: *[limits.nip49_key_bytes]u8,
    encrypted: EncryptedSecretKey,
    key: *const [limits.nip49_key_bytes]u8,
) PrivateKeyEncryptionError!void {
    const aad = [_]u8{@intFromEnum(encrypted.key_security)};
    var tag: [XChaCha20Poly1305.tag_length]u8 = undefined;
    @memcpy(tag[0..], encrypted.ciphertext[ciphertext_body_bytes..]);
    XChaCha20Poly1305.decrypt(
        output_secret_key[0..],
        encrypted.ciphertext[0..ciphertext_body_bytes],
        tag,
        aad[0..],
        encrypted.nonce,
        key.*,
    ) catch return error.InvalidCiphertext;
}

fn map_key_error(err: nostr_keys.NostrKeysError) PrivateKeyEncryptionError {
    return switch (err) {
        error.InvalidSecretKey => error.InvalidSecretKey,
        error.InvalidEvent => unreachable,
        error.BackendUnavailable => error.BackendUnavailable,
    };
}

fn wipe_bytes(bytes: []u8) void {
    std.debug.assert(bytes.len <= std.math.maxInt(usize));
    std.debug.assert(@sizeOf(u8) == 1);

    std.crypto.secureZero(u8, bytes);
}

fn map_bech32_error(err: internal_bech32.Error) PrivateKeyEncryptionError {
    return switch (err) {
        error.InvalidBech32 => error.InvalidBech32,
        error.InvalidChecksum => error.InvalidChecksum,
        error.MixedCase => error.MixedCase,
        error.InvalidPayload => error.InvalidPayload,
        error.BufferTooSmall => error.BufferTooSmall,
        error.ValueOutOfRange => error.InvalidPayload,
    };
}

fn decode_hex_secret(hex: []const u8) ![limits.nip49_key_bytes]u8 {
    var secret: [limits.nip49_key_bytes]u8 = undefined;
    _ = try std.fmt.hexToBytes(secret[0..], hex);
    return secret;
}

test "nip49 decrypts the published vector and roundtrips the canonical string" {
    const cryptsec =
        "ncryptsec1qgg9947rlpvqu76pj5ecreduf9jxhselq2nae2kghhvd5g7dgjtcxfqtd67p9m0w57" ++ "lspw8gsq6yphnm8623nsl8xn9j4jdzz84zm3frztj3z7s35vpzmqf6ksu8r89qk5z2zxfmu5gv8th" ++ "8wclt0h4p";
    const expected = try decode_hex_secret(
        "3501454135014541350145413501453fefb02227e449e57cf4d3a3ce05378683",
    );

    const encrypted = try nip49_decode_bech32(cryptsec);
    var encoded: [limits.nip49_bech32_bytes_max]u8 = undefined;
    try std.testing.expectEqualStrings(cryptsec, try nip49_encode_bech32(encoded[0..], encrypted));

    const scratch_len = try nip49_scrypt_scratch_bytes(16);
    const scratch = try std.testing.allocator.alloc(u8, @intCast(scratch_len));
    defer std.testing.allocator.free(scratch);

    var decrypted: [limits.nip49_key_bytes]u8 = undefined;
    try nip49_decrypt_from_bech32(&decrypted, cryptsec, "nostr", scratch);
    try std.testing.expectEqualSlices(u8, expected[0..], decrypted[0..]);
}

test "nip49 encrypts and decrypts deterministically with fixed salt and nonce" {
    const secret_key = [_]u8{0x11} ** limits.nip49_key_bytes;
    const salt = [_]u8{0x22} ** limits.nip49_salt_bytes;
    const nonce = [_]u8{0x33} ** limits.nip49_nonce_bytes;
    var scratch: [19_501]u8 = undefined;
    var encoded: [limits.nip49_bech32_bytes_max]u8 = undefined;
    var decrypted: [limits.nip49_key_bytes]u8 = undefined;

    const encrypted = try nip49_encrypt_with_salt_and_nonce(
        &secret_key,
        "nostr",
        4,
        .medium,
        scratch[0..],
        &salt,
        &nonce,
    );
    const cryptsec = try nip49_encode_bech32(encoded[0..], encrypted);
    try nip49_decrypt_from_bech32(&decrypted, cryptsec, "nostr", scratch[0..]);

    try std.testing.expectEqual(version_v2, encrypted.version);
    try std.testing.expectEqual(@as(u8, 4), encrypted.log_n);
    try std.testing.expectEqual(KeySecurity.medium, encrypted.key_security);
    try std.testing.expectEqualSlices(u8, secret_key[0..], decrypted[0..]);
}

test "nip49 nfkc normalization makes equivalent passwords interchangeable" {
    const secret_key = [_]u8{0x44} ** limits.nip49_key_bytes;
    const salt = [_]u8{0x55} ** limits.nip49_salt_bytes;
    const nonce = [_]u8{0x66} ** limits.nip49_nonce_bytes;
    var scratch_a: [19_501]u8 = undefined;
    var scratch_b: [19_501]u8 = undefined;

    const left = try nip49_encrypt_with_salt_and_nonce(
        &secret_key,
        "ÅΩẛ̣",
        4,
        .unknown,
        scratch_a[0..],
        &salt,
        &nonce,
    );
    const right = try nip49_encrypt_with_salt_and_nonce(
        &secret_key,
        "ÅΩṩ",
        4,
        .unknown,
        scratch_b[0..],
        &salt,
        &nonce,
    );

    try std.testing.expectEqualSlices(u8, left.ciphertext[0..], right.ciphertext[0..]);
}

test "nip49 rejects malformed payloads and wrong passwords predictably" {
    const secret_key = [_]u8{0x77} ** limits.nip49_key_bytes;
    const salt = [_]u8{0x88} ** limits.nip49_salt_bytes;
    const nonce = [_]u8{0x99} ** limits.nip49_nonce_bytes;
    var scratch: [19_501]u8 = undefined;
    var decrypted: [limits.nip49_key_bytes]u8 = undefined;

    const encrypted = try nip49_encrypt_with_salt_and_nonce(
        &secret_key,
        "test",
        4,
        .weak,
        scratch[0..],
        &salt,
        &nonce,
    );
    try std.testing.expectError(error.InvalidCiphertext, nip49_decrypt(&decrypted, encrypted, "bad", scratch[0..]));

    var raw: [limits.nip49_payload_bytes]u8 = undefined;
    _ = try nip49_serialize_bytes(raw[0..], encrypted);
    raw[0] = 0x03;
    try std.testing.expectError(error.InvalidVersion, nip49_parse_bytes(raw[0..]));
    raw[0] = version_v2;
    raw[1] = 0;
    try std.testing.expectError(error.InvalidLogN, nip49_parse_bytes(raw[0..]));
    raw[1] = encrypted.log_n;
    raw[42] = 0x09;
    try std.testing.expectError(error.InvalidKeySecurity, nip49_parse_bytes(raw[0..]));
}

test "nip49 public paths return BufferTooSmall only for real capacity failures" {
    const secret_key = [_]u8{0xAB} ** limits.nip49_key_bytes;
    const salt = [_]u8{0xBC} ** limits.nip49_salt_bytes;
    const nonce = [_]u8{0xCD} ** limits.nip49_nonce_bytes;
    var small_output: [32]u8 = undefined;
    var output: [limits.nip49_bech32_bytes_max]u8 = undefined;
    var short_scratch: [128]u8 = undefined;
    var scratch: [19_501]u8 = undefined;

    try std.testing.expectError(
        error.BufferTooSmall,
        nip49_encrypt_with_salt_and_nonce_to_bech32(
            small_output[0..],
            &secret_key,
            "ok",
            4,
            .medium,
            scratch[0..],
            &salt,
            &nonce,
        ),
    );
    try std.testing.expectError(
        error.BufferTooSmall,
        nip49_encrypt_with_salt_and_nonce_to_bech32(
            output[0..],
            &secret_key,
            "ok",
            4,
            .medium,
            short_scratch[0..],
            &salt,
            &nonce,
        ),
    );
    try std.testing.expectError(
        error.InvalidSecretKey,
        nip49_encrypt_with_salt_and_nonce_to_bech32(
            output[0..],
            &([_]u8{0} ** limits.nip49_key_bytes),
            "ok",
            4,
            .medium,
            scratch[0..],
            &salt,
            &nonce,
        ),
    );
    try std.testing.expectError(
        error.InvalidLogN,
        nip49_encrypt_with_salt_and_nonce_to_bech32(
            output[0..],
            &secret_key,
            "ok",
            0,
            .medium,
            scratch[0..],
            &salt,
            &nonce,
        ),
    );
    try std.testing.expectError(
        error.InvalidUtf8,
        nip49_encrypt_with_salt_and_nonce_to_bech32(
            output[0..],
            &secret_key,
            "\xFF",
            4,
            .medium,
            scratch[0..],
            &salt,
            &nonce,
        ),
    );
}

test "nip49 decode rejects mixed-case bech32 input" {
    const secret_key = [_]u8{0x5A} ** limits.nip49_key_bytes;
    const salt = [_]u8{0x6B} ** limits.nip49_salt_bytes;
    const nonce = [_]u8{0x7C} ** limits.nip49_nonce_bytes;
    var scratch: [19_501]u8 = undefined;
    var encoded: [limits.nip49_bech32_bytes_max]u8 = undefined;
    var mixed_case: [limits.nip49_bech32_bytes_max]u8 = undefined;

    const cryptsec = try nip49_encrypt_with_salt_and_nonce_to_bech32(
        encoded[0..],
        &secret_key,
        "nostr",
        4,
        .unknown,
        scratch[0..],
        &salt,
        &nonce,
    );
    @memcpy(mixed_case[0..cryptsec.len], cryptsec);
    mixed_case[0] = 'N';

    try std.testing.expectError(error.MixedCase, nip49_decode_bech32(mixed_case[0..cryptsec.len]));
}
