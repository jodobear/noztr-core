import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import {
    finalizeEvent,
    getEventHash,
    getPublicKey,
    type EventTemplate,
    type UnsignedEvent,
    verifyEvent,
} from "nostr-tools/pure";
import * as nostr_tools from "nostr-tools";
import { getPow } from "nostr-tools/nip13";
import { decode, noteEncode, npubEncode } from "nostr-tools/nip19";
import { makeAuthEvent } from "nostr-tools/nip42";
import { decrypt, encrypt } from "nostr-tools/nip44";
import { parse as parseNostrUri } from "nostr-tools/nip21";
import * as kinds from "nostr-tools/kinds";

type Taxonomy =
    | "LIB_SUPPORTED"
    | "HARNESS_COVERED"
    | "NOT_COVERED_IN_THIS_PASS"
    | "LIB_UNSUPPORTED";

type Depth = "BASELINE" | "EDGE" | "DEEP";

type CheckResult = "PASS" | "FAIL" | "NOT_RUN";

type NipResult = {
    nip: string;
    taxonomy: Taxonomy;
    depth: Depth;
    result: CheckResult;
    detail?: string;
};

type Fixture = {
    id: string;
    conversation_key_hex: string;
    nonce_hex: string;
    plaintext: string;
    payload_expectation_base64: string;
};

type FixtureSet = {
    set_id: string;
    fixtures: Fixture[];
};

type CapabilityProbe =
    | { kind: "supported"; detail: string }
    | { kind: "unsupported"; detail: string }
    | { kind: "inconclusive"; detail: string };

const FIXED_SECRET_KEY_HEX =
    "6b911fd37cdf5c81d4c0adb1ab7fa822ed253ab0ad9aa18d77257c88b29b718e";

function to_bytes(value_hex: string): Uint8Array {
    if (value_hex.length % 2 !== 0) {
        throw new Error("hex input must have even length");
    }
    return Uint8Array.from(Buffer.from(value_hex, "hex"));
}

function to_bytes_32(value_hex: string): Uint8Array {
    if (value_hex.length !== 64) {
        throw new Error(`expected 32-byte hex, got ${value_hex.length / 2} bytes`);
    }
    return to_bytes(value_hex);
}

function ensure(condition: boolean, detail: string): void {
    if (!condition) {
        throw new Error(detail);
    }
}

async function push_harness_covered(
    results: NipResult[],
    nip: string,
    depth: Depth,
    check: () => void | Promise<void>,
): Promise<void> {
    try {
        await check();
        results.push({ nip, taxonomy: "HARNESS_COVERED", depth, result: "PASS" });
    } catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        results.push({
            nip,
            taxonomy: "HARNESS_COVERED",
            depth,
            result: "FAIL",
            detail,
        });
    }
}

function push_not_covered(results: NipResult[], nip: string, depth: Depth, detail: string): void {
    results.push({
        nip,
        taxonomy: "NOT_COVERED_IN_THIS_PASS",
        depth,
        result: "NOT_RUN",
        detail,
    });
}

function push_lib_unsupported(
    results: NipResult[],
    nip: string,
    depth: Depth,
    detail: string,
): void {
    results.push({
        nip,
        taxonomy: "LIB_UNSUPPORTED",
        depth,
        result: "NOT_RUN",
        detail,
    });
}

function push_not_covered_with_probe(
    results: NipResult[],
    nip: string,
    depth: Depth,
    probe: CapabilityProbe,
): void {
    if (probe.kind === "supported") {
        push_not_covered(results, nip, depth, `capability_probe=supported (${probe.detail})`);
        return;
    }
    if (probe.kind === "inconclusive") {
        push_not_covered(results, nip, depth, `capability_probe=inconclusive (${probe.detail})`);
        return;
    }
    push_lib_unsupported(results, nip, depth, `capability_probe=unsupported (${probe.detail})`);
}

async function probe_module(specifier: string): Promise<CapabilityProbe> {
    try {
        await import(specifier);
        return { kind: "supported", detail: `imported ${specifier}` };
    } catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        if (
            detail.includes("Cannot find module") ||
            detail.includes("ERR_MODULE_NOT_FOUND") ||
            detail.includes("ERR_PACKAGE_PATH_NOT_EXPORTED") ||
            detail.includes("is not defined by \"exports\"")
        ) {
            return { kind: "unsupported", detail: `${specifier} missing` };
        }
        return { kind: "inconclusive", detail: `${specifier} probe failed: ${detail}` };
    }
}

async function probe_nip40(): Promise<CapabilityProbe> {
    const module_probe = await probe_module("nostr-tools/nip40");
    if (module_probe.kind === "supported") {
        return { kind: "supported", detail: "public module path nostr-tools/nip40" };
    }

    const secret_key = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const event = finalizeEvent(
        {
            kind: 1,
            created_at: 1_708_000_050,
            tags: [["expiration", "1708000350"]],
            content: "nip40 probe",
        },
        secret_key,
    );

    if (!verifyEvent(event)) {
        return { kind: "inconclusive", detail: "core event verify failed for expiration-tag probe" };
    }
    const has_expiration_tag = event.tags.some(
        tag => tag.length >= 2 && tag[0] === "expiration" && tag[1] === "1708000350",
    );
    if (!has_expiration_tag) {
        return {
            kind: "inconclusive",
            detail: "core event API did not preserve expiration tag in probe",
        };
    }
    return {
        kind: "supported",
        detail: "core event API supports expiration-tag structural path",
    };
}

async function probe_nip45(): Promise<CapabilityProbe> {
    const module_probe = await probe_module("nostr-tools/nip45");
    if (module_probe.kind === "supported") {
        return { kind: "supported", detail: "public module path nostr-tools/nip45" };
    }

    const relay_ctor = nostr_tools.Relay;
    if (relay_ctor === undefined) {
        return { kind: "unsupported", detail: "nostr-tools Relay export missing" };
    }
    const has_count = typeof relay_ctor.prototype.count === "function";
    if (!has_count) {
        return { kind: "unsupported", detail: "Relay.count method missing" };
    }
    return {
        kind: "supported",
        detail: "Relay.count public API exists for COUNT message path",
    };
}

async function probe_nip50(): Promise<CapabilityProbe> {
    const module_probe = await probe_module("nostr-tools/nip50");
    if (module_probe.kind === "supported") {
        return { kind: "supported", detail: "public module path nostr-tools/nip50" };
    }

    if (typeof nostr_tools.matchFilter !== "function") {
        return { kind: "unsupported", detail: "matchFilter export missing" };
    }
    const event = finalizeEvent(
        {
            kind: 1,
            created_at: 1_708_000_055,
            tags: [],
            content: "nostr parity",
        },
        to_bytes_32(FIXED_SECRET_KEY_HEX),
    );
    const matched = nostr_tools.matchFilter({ search: "nostr parity" }, event);
    if (typeof matched !== "boolean") {
        return { kind: "inconclusive", detail: "matchFilter did not return boolean for search" };
    }
    return {
        kind: "supported",
        detail: "filter.search accepted by matchFilter public API",
    };
}

async function probe_nip70(): Promise<CapabilityProbe> {
    const module_probe = await probe_module("nostr-tools/nip70");
    if (module_probe.kind === "supported") {
        return { kind: "supported", detail: "public module path nostr-tools/nip70" };
    }

    const secret_key = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const event = finalizeEvent(
        {
            kind: 1,
            created_at: 1_708_000_060,
            tags: [["-"]],
            content: "nip70 probe",
        },
        secret_key,
    );
    if (!verifyEvent(event)) {
        return { kind: "inconclusive", detail: "core event verify failed for protected-tag probe" };
    }
    const has_protected_tag = event.tags.some(tag => tag.length >= 1 && tag[0] === "-");
    if (!has_protected_tag) {
        return { kind: "inconclusive", detail: "core event API did not preserve '-' tag" };
    }
    return {
        kind: "supported",
        detail: "core event API supports protected-tag structural path",
    };
}

function check_nip02(): void {
    const secret_key = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const contact_pubkey =
        "f831caf722214748c72db4829986bd0cbb2bb8b3aeade1c959624a52a9629046";
    const contact_list = finalizeEvent(
        {
            kind: kinds.Contacts,
            created_at: 1_708_000_010,
            tags: [["p", contact_pubkey, "wss://relay.example"]],
            content: "",
        },
        secret_key,
    );
    ensure(contact_list.kind === kinds.Contacts, "NIP-02 contact-list kind mismatch");
    ensure(verifyEvent(contact_list), "NIP-02 contact-list verify failed");
    const has_p_tag = contact_list.tags.some(
        tag => tag.length >= 2 && tag[0] === "p" && tag[1] === contact_pubkey,
    );
    ensure(has_p_tag, "NIP-02 contact-list missing expected p tag");

    const non_contact = finalizeEvent(
        {
            kind: kinds.ShortTextNote,
            created_at: 1_708_000_011,
            tags: [],
            content: "nip02 negative",
        },
        secret_key,
    );
    const non_contact_has_p_tag = non_contact.tags.some(
        tag => tag.length >= 2 && tag[0] === "p" && tag[1] === contact_pubkey,
    );
    ensure(!non_contact_has_p_tag, "non-contact event unexpectedly contains contact p tag");
}

function check_nip09(): void {
    const secret_key = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const target_event_id =
        "7469af3be8c8e06e1b50ef1caceba30392ddc0b6614507398b7d7daa4c218e96";
    const delete_event = finalizeEvent(
        {
            kind: kinds.EventDeletion,
            created_at: 1_708_000_020,
            tags: [["e", target_event_id]],
            content: "cleanup baseline",
        },
        secret_key,
    );
    ensure(delete_event.kind === kinds.EventDeletion, "NIP-09 delete event kind mismatch");
    ensure(verifyEvent(delete_event), "NIP-09 delete event verify failed");
    const has_e_tag = delete_event.tags.some(
        tag => tag.length >= 2 && tag[0] === "e" && tag[1] === target_event_id,
    );
    ensure(has_e_tag, "NIP-09 delete event missing expected e tag");

    const non_delete = finalizeEvent(
        {
            kind: kinds.ShortTextNote,
            created_at: 1_708_000_021,
            tags: [],
            content: "nip09 negative",
        },
        secret_key,
    );
    const non_delete_has_e_tag = non_delete.tags.some(
        tag => tag.length >= 2 && tag[0] === "e" && tag[1] === target_event_id,
    );
    ensure(!non_delete_has_e_tag, "non-delete event unexpectedly contains delete e tag");
}

function check_nip65(): void {
    const secret_key = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const relay_list = finalizeEvent(
        {
            kind: kinds.RelayList,
            created_at: 1_708_000_030,
            tags: [
                ["r", "wss://relay-a.example", "read"],
                ["r", "wss://relay-b.example", "write"],
            ],
            content: "",
        },
        secret_key,
    );
    ensure(relay_list.kind === kinds.RelayList, "NIP-65 relay-list kind mismatch");
    ensure(verifyEvent(relay_list), "NIP-65 relay-list verify failed");
    const has_read_tag = relay_list.tags.some(
        tag => tag.length >= 3 && tag[0] === "r" && tag[1] === "wss://relay-a.example" &&
            tag[2] === "read",
    );
    ensure(has_read_tag, "NIP-65 relay-list missing read relay tag");
    const has_write_tag = relay_list.tags.some(
        tag => tag.length >= 3 && tag[0] === "r" && tag[1] === "wss://relay-b.example" &&
            tag[2] === "write",
    );
    ensure(has_write_tag, "NIP-65 relay-list missing write relay tag");

    const non_relay_list = finalizeEvent(
        {
            kind: kinds.ShortTextNote,
            created_at: 1_708_000_031,
            tags: [],
            content: "nip65 negative",
        },
        secret_key,
    );
    const non_relay_has_r_tag = non_relay_list.tags.some(tag => tag.length >= 1 && tag[0] === "r");
    ensure(!non_relay_has_r_tag, "non-relay-list event unexpectedly contains relay tag");
}

function check_nip01(): void {
    const secret_key = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const event_template: EventTemplate = {
        kind: 1,
        created_at: 1_708_000_000,
        tags: [],
        content: "nip01 baseline",
    };

    const event = finalizeEvent(event_template, secret_key);
    const verified = verifyEvent(event);
    ensure(verified, "verifyEvent rejected finalized event");

    const unsigned_event: UnsignedEvent = {
        pubkey: event.pubkey,
        created_at: event.created_at,
        kind: event.kind,
        tags: event.tags,
        content: event.content,
    };
    const computed_id = getEventHash(unsigned_event);
    ensure(computed_id === event.id, "event id mismatch against getEventHash");

    const tampered_event = {
        id: event.id,
        sig: event.sig,
        pubkey: event.pubkey,
        created_at: event.created_at,
        kind: event.kind,
        tags: event.tags,
        content: `${event.content}-tampered`,
    };
    ensure(!verifyEvent(tampered_event), "verifyEvent accepted tampered event payload");
}

function check_nip13(): void {
    const sample_id = "0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
    const pow_bits = getPow(sample_id);
    ensure(pow_bits === 4, `getPow mismatch: got ${pow_bits}, want 4`);

    const no_pow_bits = getPow("ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
    ensure(no_pow_bits === 0, `getPow mismatch: got ${no_pow_bits}, want 0`);
}

function check_nip19(): void {
    const pubkey_hex =
        "aa4fc8665f5696e33db7e1a572e3b0f5b3d615837b0f362dcb1c8068b098c7b4";
    const event_id_hex =
        "d94a3f4dd87b9a3b0bed183b32e916fa29c8020107845d1752d72697fe5309a5";

    const npub = npubEncode(pubkey_hex);
    const npub_decoded = decode(npub);
    ensure(npub_decoded.type === "npub", "npub decode type mismatch");
    ensure(npub_decoded.data === pubkey_hex, "npub decode payload mismatch");

    const note = noteEncode(event_id_hex);
    const note_decoded = decode(note);
    ensure(note_decoded.type === "note", "note decode type mismatch");
    ensure(note_decoded.data === event_id_hex, "note decode payload mismatch");

    let invalid_decode_rejected = false;
    try {
        decode("npub1invalid");
    } catch {
        invalid_decode_rejected = true;
    }
    ensure(invalid_decode_rejected, "invalid bech32 value unexpectedly decoded");
}

function check_nip21(): void {
    const pubkey_hex =
        "aa4fc8665f5696e33db7e1a572e3b0f5b3d615837b0f362dcb1c8068b098c7b4";
    const uri = `nostr:${npubEncode(pubkey_hex)}`;
    const parsed = parseNostrUri(uri);

    ensure(parsed.uri === uri, "NIP-21 uri mismatch after parse");
    ensure(parsed.decoded.type === "npub", "NIP-21 decoded type mismatch");
    ensure(parsed.decoded.data === pubkey_hex, "NIP-21 decoded pubkey mismatch");

    let invalid_uri_rejected = false;
    try {
        parseNostrUri("https://relay.damus.io");
    } catch {
        invalid_uri_rejected = true;
    }
    ensure(invalid_uri_rejected, "non-nostr URI unexpectedly parsed");
}

function check_nip42(): void {
    const relay_url = "wss://relay.damus.io";
    const challenge = "parity-challenge";
    const auth_template = makeAuthEvent(relay_url, challenge);

    ensure(auth_template.kind === 22242, "auth event kind mismatch");
    ensure(Array.isArray(auth_template.tags), "auth event tags are not an array");

    const has_relay_tag = auth_template.tags.some(
        tag => tag.length >= 2 && tag[0] === "relay" && tag[1] === relay_url,
    );
    ensure(has_relay_tag, "auth event missing relay tag");

    const has_challenge_tag = auth_template.tags.some(
        tag => tag.length >= 2 && tag[0] === "challenge" && tag[1] === challenge,
    );
    ensure(has_challenge_tag, "auth event missing challenge tag");

    ensure(auth_template.content === "", "auth event content should be empty");

    const wrong_challenge_tag = auth_template.tags.some(
        tag => tag.length >= 2 && tag[0] === "challenge" && tag[1] === "mismatch",
    );
    ensure(!wrong_challenge_tag, "auth event unexpectedly contains mismatched challenge tag");
}

async function check_nip11(): Promise<void> {
    const original_fetch = globalThis.fetch;
    const mock_fetch = async (url: string, init?: { headers?: Record<string, string> }) => {
        ensure(url === "https://relay.example", `unexpected NIP-11 URL: ${url}`);
        const accept = init?.headers?.Accept;
        ensure(accept === "application/nostr+json", "NIP-11 Accept header mismatch");
        return {
            async json() {
                return {
                    name: "Parity Relay",
                    supported_nips: [1, 11, 59, 77],
                    software: "https://example.com/relay",
                };
            },
        };
    };

    (globalThis as { fetch?: typeof globalThis.fetch }).fetch = mock_fetch as never;
    nostr_tools.nip11.useFetchImplementation(mock_fetch);
    try {
        const info = await nostr_tools.nip11.fetchRelayInformation("wss://relay.example");
        ensure(info.name === "Parity Relay", "NIP-11 relay name mismatch");
        ensure(Array.isArray(info.supported_nips), "NIP-11 supported_nips missing");
        ensure(info.supported_nips.includes(77), "NIP-11 supported_nips missing expected NIP");
    } finally {
        (globalThis as { fetch?: typeof globalThis.fetch }).fetch = original_fetch;
    }
}

function check_nip44(): void {
    const local_file = fileURLToPath(import.meta.url);
    const local_dir = dirname(local_file);
    const fixture_path = join(local_dir, "..", "fixtures", "nip44_ut_e_003.json");
    const fixture_text = readFileSync(fixture_path, "utf8");
    const fixture_set = JSON.parse(fixture_text) as FixtureSet;

    for (const fixture of fixture_set.fixtures) {
        const key = to_bytes_32(fixture.conversation_key_hex);
        const nonce = to_bytes_32(fixture.nonce_hex);

        const decrypted = decrypt(fixture.payload_expectation_base64, key);
        ensure(decrypted === fixture.plaintext, `${fixture.id} decrypt mismatch`);

        const encrypted = encrypt(fixture.plaintext, key, nonce);
        ensure(
            encrypted === fixture.payload_expectation_base64,
            `${fixture.id} encrypt mismatch`,
        );

        const malformed = fixture.payload_expectation_base64.slice(0, -1);
        let malformed_rejected = false;
        try {
            decrypt(malformed, key);
        } catch {
            malformed_rejected = true;
        }
        ensure(malformed_rejected, `${fixture.id} malformed payload unexpectedly decrypted`);
    }
}

function check_nip59(): void {
    const sender_private = to_bytes_32(FIXED_SECRET_KEY_HEX);
    const receiver_private = to_bytes_32(
        "7b911fd37cdf5c81d4c0adb1ab7fa822ed253ab0ad9aa18d77257c88b29b718e",
    );
    const wrong_receiver_private = to_bytes_32(
        "8b911fd37cdf5c81d4c0adb1ab7fa822ed253ab0ad9aa18d77257c88b29b718e",
    );
    const receiver_pubkey = getPublicKey(receiver_private);

    const rumor = nostr_tools.nip59.createRumor(
        {
            kind: 1,
            created_at: 1_708_000_100,
            tags: [],
            content: "nip59 baseline",
        },
        sender_private,
    );
    ensure(rumor.kind === 1, "NIP-59 rumor kind mismatch");
    ensure(rumor.content === "nip59 baseline", "NIP-59 rumor content mismatch");

    const seal = nostr_tools.nip59.createSeal(rumor, sender_private, receiver_pubkey);
    const wrap = nostr_tools.nip59.createWrap(seal, receiver_pubkey);
    const unwrapped = nostr_tools.nip59.unwrapEvent(wrap, receiver_private);
    ensure(unwrapped.id === rumor.id, "NIP-59 rumor id mismatch after unwrap");
    ensure(unwrapped.content === rumor.content, "NIP-59 rumor content mismatch after unwrap");

    let wrong_recipient_rejected = false;
    try {
        nostr_tools.nip59.unwrapEvent(wrap, wrong_receiver_private);
    } catch {
        wrong_recipient_rejected = true;
    }
    ensure(wrong_recipient_rejected, "NIP-59 unwrap accepted wrong recipient key");
}

function check_nip77(): void {
    const local = new nostr_tools.nip77.NegentropyStorageVector();
    const remote = new nostr_tools.nip77.NegentropyStorageVector();

    const local_only_id = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    const shared_id = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
    const remote_only_id = "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc";

    local.insert(1000, local_only_id);
    local.insert(1001, shared_id);
    remote.insert(1001, shared_id);
    remote.insert(1002, remote_only_id);
    local.seal();
    remote.seal();

    const local_neg = new nostr_tools.nip77.Negentropy(local);
    const remote_neg = new nostr_tools.nip77.Negentropy(remote);
    const remote_have: string[] = [];
    const remote_need: string[] = [];

    const query = local_neg.initiate();
    ensure(query.length > 0, "NIP-77 initiate produced empty query");
    const response = remote_neg.reconcile(
        query,
        id => remote_have.push(id),
        id => remote_need.push(id),
    );
    ensure(remote_have.includes(remote_only_id), "NIP-77 missing remote-only id in have callback");
    ensure(remote_need.includes(local_only_id), "NIP-77 missing local-only id in need callback");
    if (response !== null) {
        local_neg.reconcile(response);
    }

    let sealed_insert_rejected = false;
    try {
        local.insert(1003, "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
    } catch {
        sealed_insert_rejected = true;
    }
    ensure(sealed_insert_rejected, "NIP-77 storage accepted insert after seal");
}

async function main(): Promise<void> {
    const results: NipResult[] = [];

    await push_harness_covered(results, "NIP-01", "EDGE", check_nip01);
    await push_harness_covered(results, "NIP-02", "BASELINE", check_nip02);
    await push_harness_covered(results, "NIP-09", "BASELINE", check_nip09);
    await push_harness_covered(results, "NIP-11", "EDGE", check_nip11);
    await push_harness_covered(results, "NIP-13", "EDGE", check_nip13);
    await push_harness_covered(results, "NIP-19", "EDGE", check_nip19);
    await push_harness_covered(results, "NIP-21", "EDGE", check_nip21);
    await push_harness_covered(results, "NIP-42", "EDGE", check_nip42);
    await push_harness_covered(results, "NIP-44", "DEEP", check_nip44);
    await push_harness_covered(results, "NIP-59", "EDGE", check_nip59);
    await push_harness_covered(results, "NIP-65", "BASELINE", check_nip65);
    await push_harness_covered(results, "NIP-77", "EDGE", check_nip77);

    push_not_covered_with_probe(
        results,
        "NIP-40",
        "BASELINE",
        await probe_nip40(),
    );
    push_not_covered_with_probe(
        results,
        "NIP-45",
        "BASELINE",
        await probe_nip45(),
    );
    push_not_covered_with_probe(
        results,
        "NIP-50",
        "BASELINE",
        await probe_nip50(),
    );
    push_not_covered_with_probe(
        results,
        "NIP-70",
        "BASELINE",
        await probe_nip70(),
    );

    let pass_count = 0;
    let fail_count = 0;
    let harness_covered_count = 0;
    let lib_supported_count = 0;
    let not_covered_count = 0;
    let lib_unsupported_count = 0;

    for (const result of results) {
        if (result.taxonomy === "HARNESS_COVERED") {
            harness_covered_count += 1;
            if (result.result === "PASS") {
                pass_count += 1;
            }
            if (result.result === "FAIL") {
                fail_count += 1;
            }
        }
        if (result.taxonomy === "LIB_SUPPORTED") {
            lib_supported_count += 1;
        }
        if (result.taxonomy === "NOT_COVERED_IN_THIS_PASS") {
            not_covered_count += 1;
        }
        if (result.taxonomy === "LIB_UNSUPPORTED") {
            lib_unsupported_count += 1;
        }

        const detail_suffix = result.detail === undefined ? "" : ` | detail=${result.detail}`;
        console.log(
            `${result.nip} | taxonomy=${result.taxonomy} | depth=${result.depth} | result=${result.result}${detail_suffix}`,
        );
    }

    console.log(
        "SUMMARY " +
            `pass=${pass_count} fail=${fail_count} harness_covered=${harness_covered_count} ` +
            `lib_supported=${lib_supported_count} not_covered_in_this_pass=${not_covered_count} ` +
            `lib_unsupported=${lib_unsupported_count} total=${results.length}`,
    );

    if (fail_count > 0) {
        process.exit(1);
    }
}

await main();
