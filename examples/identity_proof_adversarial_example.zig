const std = @import("std");
const noztr = @import("noztr");

test "adversarial identity-proof example: reject platform identity overflow on typed path" {
    var built_tag: noztr.nip39_external_identities.BuiltTag = .{};
    var edge_identity: [noztr.limits.tag_item_bytes_max]u8 = undefined;
    @memset(edge_identity[0..], 'a');
    const claim = noztr.nip39_external_identities.IdentityClaim{
        .provider = .github,
        .identity = edge_identity[0..],
        .proof = "9721ce4ee4fceb91c9711ca2a6c9a5ab",
    };

    try std.testing.expectError(
        error.InvalidIdentity,
        noztr.nip39_external_identities.identity_claim_build_tag(&built_tag, &claim),
    );
}
