const std = @import("std");
const limits = @import("limits.zig");
const nip01_event = @import("nip01_event.zig");

pub const text_note_event_kind: u32 = 1;

const nip10_e_tag_items_max: u8 = 5;
const nip10_marker_bytes_max: u8 = 5;

pub const ThreadError = error{
    InvalidEventKind,
    InvalidETag,
    InvalidEventId,
    InvalidRelayHint,
    InvalidMarker,
    InvalidPubkey,
    DuplicateRootTag,
    DuplicateReplyTag,
    BufferTooSmall,
};

pub const ThreadMarker = enum {
    root,
    reply,
};

pub const ThreadReference = struct {
    event_id: [32]u8,
    relay_hint: ?[]const u8 = null,
    author_pubkey: ?[32]u8 = null,
};

pub const ThreadInfo = struct {
    root: ?ThreadReference = null,
    reply: ?ThreadReference = null,
    mention_count: u16 = 0,
};

const ParsedThreadTag = struct {
    reference: ThreadReference,
    marker: ?ThreadMarker = null,
};

const MarkerAndPubkey = struct {
    marker: ?ThreadMarker = null,
    author_pubkey: ?[32]u8 = null,
};

/// Parses a NIP-10 thread marker token.
pub fn thread_marker_parse(marker: []const u8) error{InvalidMarker}!ThreadMarker {
    std.debug.assert(marker.len <= limits.tag_item_bytes_max);
    std.debug.assert(nip10_marker_bytes_max == 5);

    if (marker.len > nip10_marker_bytes_max) {
        return error.InvalidMarker;
    }
    if (std.mem.eql(u8, marker, "root")) {
        return .root;
    }
    if (std.mem.eql(u8, marker, "reply")) {
        return .reply;
    }
    return error.InvalidMarker;
}

/// Extracts strict NIP-10 thread references from a kind-1 text note into caller-owned mentions.
pub fn thread_extract(
    event: *const nip01_event.Event,
    mentions_out: []ThreadReference,
) ThreadError!ThreadInfo {
    std.debug.assert(@intFromPtr(event) != 0);
    std.debug.assert(mentions_out.len <= std.math.maxInt(u16));

    if (event.kind != text_note_event_kind) {
        return error.InvalidEventKind;
    }

    var info = ThreadInfo{};
    var saw_marked_tag = false;
    var mention_count: u16 = 0;
    for (event.tags) |tag| {
        const parsed = try parse_thread_tag(tag);
        if (parsed == null) {
            continue;
        }
        if (parsed.?.marker) |marker| {
            saw_marked_tag = true;
            try apply_marked_reference(&info, marker, parsed.?.reference);
            continue;
        }
        if (mention_count == mentions_out.len) {
            return error.BufferTooSmall;
        }
        mentions_out[mention_count] = parsed.?.reference;
        mention_count += 1;
    }

    if (saw_marked_tag) {
        info.mention_count = mention_count;
        if (info.root != null and info.reply == null) {
            info.reply = info.root;
        }
        return info;
    }

    return apply_positional_fallback(mentions_out, mention_count);
}

fn apply_marked_reference(
    info: *ThreadInfo,
    marker: ThreadMarker,
    reference: ThreadReference,
) ThreadError!void {
    std.debug.assert(@intFromPtr(info) != 0);
    std.debug.assert(@intFromEnum(marker) <= @intFromEnum(ThreadMarker.reply));

    if (marker == .root) {
        if (info.root != null) {
            return error.DuplicateRootTag;
        }
        info.root = reference;
        return;
    }
    if (info.reply != null) {
        return error.DuplicateReplyTag;
    }
    info.reply = reference;
}

fn apply_positional_fallback(
    mentions_out: []ThreadReference,
    total_count: u16,
) ThreadInfo {
    std.debug.assert(mentions_out.len <= std.math.maxInt(u16));
    std.debug.assert(total_count <= mentions_out.len);

    var info = ThreadInfo{};
    if (total_count == 0) {
        return info;
    }

    info.root = mentions_out[0];
    if (total_count == 1) {
        info.reply = mentions_out[0];
        return info;
    }

    info.reply = mentions_out[total_count - 1];
    if (total_count == 2) {
        return info;
    }

    var index: u16 = 1;
    while (index < total_count - 1) : (index += 1) {
        mentions_out[index - 1] = mentions_out[index];
    }
    info.mention_count = total_count - 2;
    return info;
}

fn parse_thread_tag(tag: nip01_event.EventTag) ThreadError!?ParsedThreadTag {
    std.debug.assert(tag.items.len <= limits.tag_items_max);
    std.debug.assert(nip10_e_tag_items_max == 5);

    if (tag.items.len == 0) {
        return error.InvalidETag;
    }
    if (!std.mem.eql(u8, tag.items[0], "e")) {
        return null;
    }
    if (tag.items.len < 2) {
        return error.InvalidETag;
    }
    if (tag.items.len > nip10_e_tag_items_max) {
        return error.InvalidETag;
    }

    const event_id = parse_lower_hex_32(tag.items[1]) catch {
        return error.InvalidEventId;
    };
    var relay_hint: ?[]const u8 = null;
    if (tag.items.len >= 3) {
        relay_hint = parse_optional_hint(tag.items[2]) catch {
            return error.InvalidRelayHint;
        };
    }
    const parsed_tail = try parse_marker_and_pubkey(tag);

    return .{
        .reference = .{
            .event_id = event_id,
            .relay_hint = relay_hint,
            .author_pubkey = parsed_tail.author_pubkey,
        },
        .marker = parsed_tail.marker,
    };
}

fn parse_marker_and_pubkey(tag: nip01_event.EventTag) ThreadError!MarkerAndPubkey {
    std.debug.assert(tag.items.len <= limits.tag_items_max);
    std.debug.assert(nip10_e_tag_items_max == 5);

    var tag_3: ?[]const u8 = null;
    if (tag.items.len >= 4 and tag.items[3].len > 0) {
        tag_3 = tag.items[3];
    }
    var tag_4: ?[]const u8 = null;
    if (tag.items.len >= 5 and tag.items[4].len > 0) {
        tag_4 = tag.items[4];
    }

    var parsed = MarkerAndPubkey{};
    if (tag_3 != null and tag_4 != null) {
        parsed.marker = thread_marker_parse(tag_3.?) catch return error.InvalidMarker;
        parsed.author_pubkey = try parse_pubkey(tag_4.?);
        return parsed;
    }
    if (tag_3 != null and tag_4 == null) {
        const maybe_marker = thread_marker_parse(tag_3.?) catch null;
        if (maybe_marker) |marker| {
            parsed.marker = marker;
            return parsed;
        }
        return error.InvalidMarker;
    }
    if (tag_3 == null and tag_4 != null) {
        parsed.author_pubkey = try parse_pubkey(tag_4.?);
    }
    return parsed;
}

fn parse_pubkey(text: []const u8) ThreadError![32]u8 {
    std.debug.assert(text.len <= limits.tag_item_bytes_max);
    std.debug.assert(limits.pubkey_hex_length == 64);

    return parse_lower_hex_32(text) catch {
        return error.InvalidPubkey;
    };
}

fn parse_optional_hint(text: []const u8) error{InvalidHint}!?[]const u8 {
    std.debug.assert(text.len <= limits.tag_item_bytes_max);
    std.debug.assert(text.len >= 0);

    if (text.len == 0) {
        return null;
    }
    if (!std.unicode.utf8ValidateSlice(text)) {
        return error.InvalidHint;
    }
    return text;
}

fn parse_lower_hex_32(text: []const u8) error{InvalidHex}![32]u8 {
    std.debug.assert(text.len <= limits.tag_item_bytes_max);
    std.debug.assert(limits.id_hex_length == 64);

    var output: [32]u8 = undefined;
    if (text.len != limits.id_hex_length) {
        return error.InvalidHex;
    }
    try validate_lower_hex(text);
    _ = std.fmt.hexToBytes(&output, text) catch {
        return error.InvalidHex;
    };
    return output;
}

fn validate_lower_hex(text: []const u8) error{InvalidHex}!void {
    std.debug.assert(text.len <= limits.tag_item_bytes_max);
    std.debug.assert(limits.id_hex_length == 64);

    for (text) |byte| {
        const is_digit = byte >= '0' and byte <= '9';
        if (is_digit) {
            continue;
        }
        const is_hex = byte >= 'a' and byte <= 'f';
        if (!is_hex) {
            return error.InvalidHex;
        }
    }
}

fn thread_event(tags: []const nip01_event.EventTag) nip01_event.Event {
    std.debug.assert(tags.len <= limits.tags_max);
    std.debug.assert(text_note_event_kind == 1);

    return .{
        .id = [_]u8{0} ** 32,
        .pubkey = [_]u8{0} ** 32,
        .sig = [_]u8{0} ** 64,
        .kind = text_note_event_kind,
        .created_at = 0,
        .content = "",
        .tags = tags,
    };
}

test "thread marker parse accepts root and reply" {
    try std.testing.expectEqual(ThreadMarker.root, try thread_marker_parse("root"));
    try std.testing.expectEqual(ThreadMarker.reply, try thread_marker_parse("reply"));
}

test "thread extract marked root-only reply infers direct reply" {
    const root_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
        "wss://relay.root",
        "root",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    };
    const tags = [_]nip01_event.EventTag{.{ .items = root_tag[0..] }};
    const event = thread_event(tags[0..]);
    var mentions: [1]ThreadReference = undefined;

    const parsed = try thread_extract(&event, mentions[0..]);

    try std.testing.expect(parsed.root != null);
    try std.testing.expect(parsed.reply != null);
    try std.testing.expect(parsed.root.?.event_id[0] == 0x11);
    try std.testing.expect(parsed.reply.?.event_id[0] == 0x11);
    try std.testing.expectEqualStrings("wss://relay.root", parsed.root.?.relay_hint.?);
    try std.testing.expect(parsed.root.?.author_pubkey.?[0] == 0xaa);
    try std.testing.expectEqual(@as(u16, 0), parsed.mention_count);
}

test "thread extract marked tags keep unmarked mentions and empty hints absent" {
    const root_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
        "",
        "root",
    };
    const reply_tag = [_][]const u8{
        "e",
        "2222222222222222222222222222222222222222222222222222222222222222",
        "wss://relay.reply",
        "reply",
        "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    };
    const mention_tag = [_][]const u8{
        "e",
        "3333333333333333333333333333333333333333333333333333333333333333",
        "",
        "",
        "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
    };
    const tags = [_]nip01_event.EventTag{
        .{ .items = root_tag[0..] },
        .{ .items = mention_tag[0..] },
        .{ .items = reply_tag[0..] },
    };
    const event = thread_event(tags[0..]);
    var mentions: [2]ThreadReference = undefined;

    const parsed = try thread_extract(&event, mentions[0..]);

    try std.testing.expect(parsed.root != null);
    try std.testing.expect(parsed.reply != null);
    try std.testing.expect(parsed.root.?.relay_hint == null);
    try std.testing.expect(parsed.reply.?.event_id[0] == 0x22);
    try std.testing.expect(parsed.reply.?.author_pubkey.?[0] == 0xbb);
    try std.testing.expectEqual(@as(u16, 1), parsed.mention_count);
    try std.testing.expect(mentions[0].event_id[0] == 0x33);
    try std.testing.expect(mentions[0].relay_hint == null);
    try std.testing.expect(mentions[0].author_pubkey.?[0] == 0xcc);
}

test "thread extract rejects 4-slot pubkey in marker position" {
    const widened_tag = [_][]const u8{
        "e",
        "3333333333333333333333333333333333333333333333333333333333333333",
        "",
        "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
    };
    var mentions: [1]ThreadReference = undefined;

    try std.testing.expectError(
        error.InvalidMarker,
        thread_extract(&thread_event(&.{.{ .items = widened_tag[0..] }}), mentions[0..]),
    );
}

test "thread extract positional fallback resolves root mentions and reply" {
    const root_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
    };
    const mention_tag = [_][]const u8{
        "e",
        "2222222222222222222222222222222222222222222222222222222222222222",
    };
    const reply_tag = [_][]const u8{
        "e",
        "3333333333333333333333333333333333333333333333333333333333333333",
        "wss://relay.reply",
    };
    const tags = [_]nip01_event.EventTag{
        .{ .items = root_tag[0..] },
        .{ .items = mention_tag[0..] },
        .{ .items = reply_tag[0..] },
    };
    const event = thread_event(tags[0..]);
    var mentions: [3]ThreadReference = undefined;

    const parsed = try thread_extract(&event, mentions[0..]);

    try std.testing.expect(parsed.root != null);
    try std.testing.expect(parsed.reply != null);
    try std.testing.expect(parsed.root.?.event_id[0] == 0x11);
    try std.testing.expect(parsed.reply.?.event_id[0] == 0x33);
    try std.testing.expectEqualStrings("wss://relay.reply", parsed.reply.?.relay_hint.?);
    try std.testing.expectEqual(@as(u16, 1), parsed.mention_count);
    try std.testing.expect(mentions[0].event_id[0] == 0x22);
}

test "thread extract positional fallback with one e tag uses same root and reply" {
    const reply_tag = [_][]const u8{
        "e",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    };
    const tags = [_]nip01_event.EventTag{.{ .items = reply_tag[0..] }};
    const event = thread_event(tags[0..]);
    var mentions: [1]ThreadReference = undefined;

    const parsed = try thread_extract(&event, mentions[0..]);

    try std.testing.expect(parsed.root != null);
    try std.testing.expect(parsed.reply != null);
    try std.testing.expect(parsed.root.?.event_id[0] == 0xaa);
    try std.testing.expect(parsed.reply.?.event_id[0] == 0xaa);
    try std.testing.expectEqual(@as(u16, 0), parsed.mention_count);
}

test "thread extract rejects wrong kind duplicates and marker misuse" {
    const root_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
        "",
        "root",
    };
    const duplicate_root_tags = [_]nip01_event.EventTag{
        .{ .items = root_tag[0..] },
        .{ .items = root_tag[0..] },
    };
    const bad_marker_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
        "",
        "mention",
    };
    const bad_marker_tags = [_]nip01_event.EventTag{.{ .items = bad_marker_tag[0..] }};
    var out: [2]ThreadReference = undefined;

    try std.testing.expectError(error.DuplicateRootTag, thread_extract(&thread_event(
        duplicate_root_tags[0..],
    ), out[0..]));

    try std.testing.expectError(error.InvalidMarker, thread_extract(&thread_event(
        bad_marker_tags[0..],
    ), out[0..]));

    try std.testing.expectError(
        error.InvalidEventKind,
        thread_extract(
            &.{
                .id = [_]u8{0} ** 32,
                .pubkey = [_]u8{0} ** 32,
                .sig = [_]u8{0} ** 64,
                .kind = 42,
                .created_at = 0,
                .content = "",
                .tags = bad_marker_tags[0..],
            },
            out[0..],
        ),
    );
}

test "thread extract rejects malformed tags and output overflow" {
    const bad_id_tag = [_][]const u8{ "e", "xyz" };
    const bad_pubkey_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
        "",
        "",
        "xyz",
    };
    const too_many_items_tag = [_][]const u8{
        "e",
        "1111111111111111111111111111111111111111111111111111111111111111",
        "",
        "",
        "",
        "extra",
    };
    const good_tag = [_][]const u8{
        "e",
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    };
    const overflow_tags = [_]nip01_event.EventTag{
        .{ .items = good_tag[0..] },
        .{ .items = good_tag[0..] },
    };
    var out: [1]ThreadReference = undefined;

    try std.testing.expectError(
        error.InvalidEventId,
        thread_extract(&thread_event(&.{.{ .items = bad_id_tag[0..] }}), out[0..]),
    );
    try std.testing.expectError(
        error.InvalidPubkey,
        thread_extract(&thread_event(&.{.{ .items = bad_pubkey_tag[0..] }}), out[0..]),
    );
    try std.testing.expectError(
        error.InvalidETag,
        thread_extract(&thread_event(&.{.{ .items = too_many_items_tag[0..] }}), out[0..]),
    );
    try std.testing.expectError(
        error.BufferTooSmall,
        thread_extract(&thread_event(overflow_tags[0..]), out[0..]),
    );
}
