const std = @import("std");
const noztr = @import("noztr");

test "NIP-73 example: parse external ids and build canonical i tags" {
    const external_id = try noztr.nip73_external_ids.external_id_parse(
        "https://example.com/article",
        null,
    );
    var built: noztr.nip73_external_ids.BuiltTag = .{};
    const tag = try noztr.nip73_external_ids.external_id_build_i_tag(&built, &external_id);

    try std.testing.expect(external_id.kind == .web);
    try std.testing.expectEqualStrings("i", tag.items[0]);
}

test "NIP-73 example: parse blockchain transaction ids" {
    const external_id = try noztr.nip73_external_ids.external_id_parse(
        "bitcoin:tx:98f7812be496f97f80e2e98d66358d1fc733cf34176a8356d171ea7fbbe97ccd",
        null,
    );

    try std.testing.expect(external_id.kind == .blockchain_tx);
    try std.testing.expectEqualStrings("bitcoin", external_id.kind.blockchain_tx);
    try std.testing.expectEqualStrings(
        "bitcoin:tx:98f7812be496f97f80e2e98d66358d1fc733cf34176a8356d171ea7fbbe97ccd",
        external_id.value,
    );
}
