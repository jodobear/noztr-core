const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

const AuthFixture = struct {
    relay_items: [2][]const u8,
    challenge_items: [2][]const u8,
    tags: [2]noztr.nip01_event.EventTag,

    fn init(self: *AuthFixture, relay: []const u8, challenge: []const u8) void {
        self.* = .{
            .relay_items = .{ "relay", relay },
            .challenge_items = .{ "challenge", challenge },
            .tags = undefined,
        };
        self.tags[0] = .{ .items = self.relay_items[0..] };
        self.tags[1] = .{ .items = self.challenge_items[0..] };
    }
};

test "NIP-42 example: auth validation and protected-event gating compose directly" {
    const secret_key = [_]u8{0x31} ** 32;
    const pubkey = try common.derive_public_key(&secret_key);
    var state = noztr.nip42_auth.AuthState{};
    var fixture: AuthFixture = undefined;
    const protected_items = [_][]const u8{"-"};
    const protected_tags = [_]noztr.nip01_event.EventTag{.{ .items = protected_items[0..] }};
    var auth_event = common.simple_event(noztr.nip42_auth.auth_event_kind, pubkey, "", &.{});

    noztr.nip42_auth.auth_state_init(&state);
    try noztr.nip42_auth.auth_state_set_challenge(&state, "relay-challenge");
    fixture.init("wss://relay.example.com/chat", "relay-challenge");
    auth_event.tags = fixture.tags[0..];
    auth_event.created_at = 42;
    try common.sign_event(&secret_key, &auth_event);

    try noztr.nip42_auth.auth_validate_event(
        &auth_event,
        "wss://relay.example.com/chat",
        "relay-challenge",
        45,
        60,
    );
    try noztr.nip42_auth.auth_state_accept_event(
        &state,
        &auth_event,
        "wss://relay.example.com/chat",
        45,
        60,
    );

    const protected_event = common.simple_event(1, pubkey, "secret", protected_tags[0..]);
    try std.testing.expectEqual(@as(u16, 1), state.authenticated_count);
    try std.testing.expect(noztr.nip42_auth.auth_state_is_pubkey_authenticated(&state, &pubkey));
    try noztr.nip70_protected.protected_event_validate(
        &protected_event,
        if (noztr.nip42_auth.auth_state_is_pubkey_authenticated(&state, &pubkey)) &pubkey else null,
    );
}
