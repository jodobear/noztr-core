const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-66 adversarial example: reject invalid discovery identity" {
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "d", "https://relay.example" } },
    };
    const event = common.simple_event(
        noztr.nip66_relay_discovery.discovery_kind,
        [_]u8{0x66} ** 32,
        "",
        tags[0..],
    );
    var supported_nips: [1]u16 = undefined;
    var requirements: [1]noztr.nip66_relay_discovery.RelayRequirement = undefined;
    var topics: [1][]const u8 = undefined;
    var kind_policies: [1]noztr.nip66_relay_discovery.RelayKindPolicy = undefined;

    try std.testing.expectError(
        error.InvalidIdentifierTag,
        noztr.nip66_relay_discovery.relay_discovery_extract(
            &event,
            supported_nips[0..],
            requirements[0..],
            topics[0..],
            kind_policies[0..],
        ),
    );
}

test "NIP-66 adversarial example: reject malformed timeout tag" {
    const tags = [_]noztr.nip01_event.EventTag{
        .{ .items = &.{ "frequency", "3600" } },
        .{ .items = &.{ "timeout", "open", "read" } },
    };
    const event = common.simple_event(
        noztr.nip66_relay_discovery.monitor_kind,
        [_]u8{0x67} ** 32,
        "",
        tags[0..],
    );
    var timeouts: [1]noztr.nip66_relay_discovery.RelayMonitorTimeout = undefined;
    var checks: [1][]const u8 = undefined;

    try std.testing.expectError(
        error.InvalidTimeoutTag,
        noztr.nip66_relay_discovery.relay_monitor_extract(&event, timeouts[0..], checks[0..]),
    );
}

