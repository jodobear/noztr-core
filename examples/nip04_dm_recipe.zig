const std = @import("std");
const noztr = @import("noztr");
const common = @import("common.zig");

test "recipe: build sign parse and verify a legacy kind-4 DM event" {
    const sender_secret = [_]u8{0x11} ** 32;
    const recipient_secret = [_]u8{0x22} ** 32;
    const sender_pubkey = try common.derive_public_key(&sender_secret);
    const recipient_pubkey = try common.derive_public_key(&recipient_secret);
    const recipient_hex = std.fmt.bytesToHex(recipient_pubkey, .lower);
    var recipient_tag: noztr.nip04.BuiltTag = .{};
    const built_recipient = try noztr.nip04.nip04_build_recipient_tag(&recipient_tag, recipient_hex[0..]);
    const tags = [_]noztr.nip01_event.EventTag{built_recipient};
    const iv = [_]u8{0x55} ** noztr.limits.nip04_iv_bytes;
    var content_storage: [noztr.limits.content_bytes_max]u8 = undefined;
    const payload = try noztr.nip04.nip04_encrypt_with_iv(
        content_storage[0..],
        &sender_secret,
        &recipient_pubkey,
        "hello kind4",
        &iv,
    );
    var event = common.simple_event(4, sender_pubkey, payload, tags[0..]);

    try common.sign_event(&sender_secret, &event);
    try noztr.nip01_event.event_verify(&event);

    const parsed = try noztr.nip04.nip04_message_parse(&event);
    try std.testing.expect(std.mem.eql(u8, &parsed.recipient_pubkey, &recipient_pubkey));

    var plaintext: [noztr.limits.nip04_plaintext_max_bytes]u8 = undefined;
    const decrypted = try noztr.nip04.nip04_decrypt(
        plaintext[0..],
        &recipient_secret,
        &event.pubkey,
        parsed.content,
    );
    try std.testing.expectEqualStrings("hello kind4", decrypted);
}
