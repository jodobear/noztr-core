const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "NIP-66 example: extract relay discovery and monitor metadata" {
    var discovery_id = noztr.nip66_relay_discovery.TagBuilder{};
    var discovery_rtt = noztr.nip66_relay_discovery.TagBuilder{};
    var discovery_network = noztr.nip66_relay_discovery.TagBuilder{};
    var discovery_nip = noztr.nip66_relay_discovery.TagBuilder{};
    var discovery_requirement = noztr.nip66_relay_discovery.TagBuilder{};
    var discovery_topic = noztr.nip66_relay_discovery.TagBuilder{};
    var discovery_geo = noztr.nip66_relay_discovery.TagBuilder{};
    var monitor_frequency = noztr.nip66_relay_discovery.TagBuilder{};
    var monitor_timeout = noztr.nip66_relay_discovery.TagBuilder{};
    var monitor_check = noztr.nip66_relay_discovery.TagBuilder{};
    const discovery_tags = [_]noztr.nip01_event.EventTag{
        try noztr.nip66_relay_discovery.discovery_build_url_tag(
            &discovery_id,
            "wss://relay.example",
        ),
        try noztr.nip66_relay_discovery.discovery_build_rtt_tag(
            &discovery_rtt,
            .open,
            200,
        ),
        try noztr.nip66_relay_discovery.discovery_build_network_tag(
            &discovery_network,
            "clearnet",
        ),
        try noztr.nip66_relay_discovery.discovery_build_supported_nip_tag(
            &discovery_nip,
            11,
        ),
        try noztr.nip66_relay_discovery.discovery_build_requirement_tag(
            &discovery_requirement,
            "auth",
            true,
        ),
        try noztr.nip66_relay_discovery.discovery_build_topic_tag(
            &discovery_topic,
            "nostr",
        ),
        try noztr.nip66_relay_discovery.discovery_build_geohash_tag(
            &discovery_geo,
            "ww8p1r4t8",
        ),
    };
    const monitor_tags = [_]noztr.nip01_event.EventTag{
        try noztr.nip66_relay_discovery.monitor_build_frequency_tag(
            &monitor_frequency,
            3600,
        ),
        try noztr.nip66_relay_discovery.monitor_build_timeout_tag(
            &monitor_timeout,
            3000,
            "open",
        ),
        try noztr.nip66_relay_discovery.monitor_build_check_tag(&monitor_check, "dns"),
    };
    const discovery_event = common.simple_event(
        noztr.nip66_relay_discovery.discovery_kind,
        [_]u8{0x66} ** 32,
        "{\"name\":\"relay\"}",
        discovery_tags[0..],
    );
    const monitor_event = common.simple_event(
        noztr.nip66_relay_discovery.monitor_kind,
        [_]u8{0x67} ** 32,
        "",
        monitor_tags[0..],
    );
    var supported_nips: [1]u16 = undefined;
    var requirements: [1]noztr.nip66_relay_discovery.RelayRequirement = undefined;
    var topics: [1][]const u8 = undefined;
    var kind_policies: [1]noztr.nip66_relay_discovery.RelayKindPolicy = undefined;
    var timeouts: [1]noztr.nip66_relay_discovery.RelayMonitorTimeout = undefined;
    var checks: [1][]const u8 = undefined;

    const discovery = try noztr.nip66_relay_discovery.discovery_extract(
        &discovery_event,
        supported_nips[0..],
        requirements[0..],
        topics[0..],
        kind_policies[0..],
    );
    const monitor = try noztr.nip66_relay_discovery.monitor_extract(
        &monitor_event,
        timeouts[0..],
        checks[0..],
    );

    try std.testing.expect(discovery.identity == .relay_url);
    try std.testing.expectEqual(@as(?u32, 200), discovery.open_rtt_ms);
    try std.testing.expectEqual(@as(u16, 1), discovery.supported_nip_count);
    try std.testing.expectEqualStrings("auth", requirements[0].name);
    try std.testing.expectEqualStrings("nostr", topics[0]);
    try std.testing.expectEqual(@as(u64, 3600), monitor.frequency_seconds);
    try std.testing.expectEqualStrings("open", timeouts[0].check.?);
    try std.testing.expectEqualStrings("dns", checks[0]);
}
