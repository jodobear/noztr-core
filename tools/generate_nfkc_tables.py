#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path
import unicodedata


OUT_PATH = Path("src/unicode_nfkc_data.zig")


def should_skip_codepoint(cp: int) -> bool:
    return 0xD800 <= cp <= 0xDFFF


def format_entries(entries: list[tuple[int, int, int]]) -> str:
    lines: list[str] = []
    for starter, combining, composed in entries:
        lines.append(
            "    "
            f".{{ .starter = 0x{starter:04X}, .combining = 0x{combining:04X}, "
            f".composed = 0x{composed:04X} }},"
        )
    return "\n".join(lines)


def build_compositions() -> list[tuple[int, int, int]]:
    entries: list[tuple[int, int, int]] = []

    for cp in range(0x110000):
        if should_skip_codepoint(cp):
            continue
        if 0xAC00 <= cp <= 0xD7A3:
            continue

        decomposition = unicodedata.decomposition(chr(cp))
        if not decomposition or decomposition.startswith("<"):
            continue

        fields = decomposition.split()
        if len(fields) != 2:
            continue

        starter = int(fields[0], 16)
        combining = int(fields[1], 16)
        pair = chr(starter) + chr(combining)
        if unicodedata.normalize("NFC", pair) != chr(cp):
            continue

        entries.append((starter, combining, cp))

    entries.sort()
    return entries


def main() -> None:
    entries = build_compositions()
    OUT_PATH.write_text(
        "\n".join(
            [
                "const std = @import(\"std\");",
                "",
                "pub const CompositionEntry = struct {",
                "    starter: u32,",
                "    combining: u32,",
                "    composed: u32,",
                "};",
                "",
                f"pub const unicode_version = \"{unicodedata.unidata_version}\";",
                "",
                "pub const composition_entries = [_]CompositionEntry{",
                format_entries(entries),
                "};",
                "",
                "test \"generated nfkc composition tables are populated\" {",
                "    try std.testing.expect(composition_entries.len > 0);",
                "}",
                "",
            ]
        )
    )


if __name__ == "__main__":
    main()
