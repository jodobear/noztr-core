const std = @import("std");
const libwally = @import("libwally");
const limits = @import("../limits.zig");

pub const c = libwally.c;
pub const hardened_bit: u32 = c.BIP32_INITIAL_HARDENED_CHILD;
pub const private_skip_hash: u32 = c.BIP32_FLAG_KEY_PRIVATE | c.BIP32_FLAG_SKIP_HASH;

pub const LibwallyBackendError = error{
    BackendUnavailable,
    DerivationFailure,
};

const BackendState = struct {
    once: @TypeOf(std.once(init_backend_once)) = std.once(init_backend_once),
    err: ?LibwallyBackendError = null,
};

var backend_state = BackendState{};

pub fn ensure_ready() LibwallyBackendError!void {
    std.debug.assert(backend_state.err == null or @intFromError(backend_state.err.?) >= 0);
    std.debug.assert(!@inComptime());

    backend_state.once.call();
    if (backend_state.err) |err| return err;
}

pub fn create_master_key_from_seed(
    seed: []const u8,
    output: *c.struct_ext_key,
) LibwallyBackendError!void {
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

pub fn derive_hardened_child(
    parent: *const c.struct_ext_key,
    index: u32,
    output: *c.struct_ext_key,
) LibwallyBackendError!void {
    std.debug.assert(index < hardened_bit);
    std.debug.assert(@sizeOf(c.struct_ext_key) > 0);

    const child_index = hardened_bit | index;
    const result = c.bip32_key_from_parent(parent, child_index, private_skip_hash, output);
    if (result != c.WALLY_OK) return error.DerivationFailure;
}

pub fn derive_normal_child(
    parent: *const c.struct_ext_key,
    index: u32,
    output: *c.struct_ext_key,
) LibwallyBackendError!void {
    std.debug.assert(index < hardened_bit);
    std.debug.assert(@sizeOf(c.struct_ext_key) > 0);

    const result = c.bip32_key_from_parent(parent, index, private_skip_hash, output);
    if (result != c.WALLY_OK) return error.DerivationFailure;
}

pub fn derive_hardened_path(
    parent: *const c.struct_ext_key,
    path: []const u32,
    output: *c.struct_ext_key,
) LibwallyBackendError!void {
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

fn init_backend_once() void {
    std.debug.assert(!@inComptime());
    std.debug.assert(backend_state.err == null);

    if (c.wally_init(0) != c.WALLY_OK) {
        backend_state.err = error.BackendUnavailable;
        return;
    }

    var entropy: [c.WALLY_SECP_RANDOMIZE_LEN]u8 = undefined;
    std.crypto.random.bytes(&entropy);
    defer wipe_bytes(entropy[0..]);
    if (c.wally_secp_randomize(&entropy, entropy.len) != c.WALLY_OK) {
        backend_state.err = error.BackendUnavailable;
    }
}

fn wipe_bytes(bytes: []u8) void {
    std.debug.assert(bytes.len >= 0);
    std.debug.assert(!@inComptime());

    std.crypto.secureZero(u8, bytes);
}
