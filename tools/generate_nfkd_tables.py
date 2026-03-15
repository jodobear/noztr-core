#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path
import unicodedata


OUT_PATH = Path("src/unicode_nfkd_data.zig")


def format_u32_array(values: list[int]) -> str:
    lines: list[str] = []
    current = "    "
    for value in values:
        item = f"0x{value:04X}, "
        if len(current) + len(item) > 96:
            lines.append(current.rstrip())
            current = "    " + item
        else:
            current += item
    if current.strip():
        lines.append(current.rstrip())
    return "\n".join(lines)


def format_struct_array(entries: list[tuple[int, int]]) -> str:
    lines: list[str] = []
    for cp, ccc in entries:
        lines.append(f"    .{{ .cp = 0x{cp:04X}, .ccc = {ccc} }},")
    return "\n".join(lines)


def format_mapping_array(entries: list[tuple[int, int, int]]) -> str:
    lines: list[str] = []
    for cp, offset, length in entries:
        lines.append(
            f"    .{{ .cp = 0x{cp:04X}, .offset = {offset}, .len = {length} }},"
        )
    return "\n".join(lines)


def should_skip_codepoint(cp: int) -> bool:
    return 0xD800 <= cp <= 0xDFFF


def build_tables() -> tuple[list[tuple[int, int, int]], list[int], list[tuple[int, int]]]:
    mappings: list[tuple[int, int, int]] = []
    scalars: list[int] = []
    combining_entries: list[tuple[int, int]] = []

    for cp in range(0x110000):
        if should_skip_codepoint(cp):
            continue

        ccc = unicodedata.combining(chr(cp))
        if ccc != 0:
            combining_entries.append((cp, ccc))

        if 0xAC00 <= cp <= 0xD7A3:
            continue

        normalized = unicodedata.normalize("NFKD", chr(cp))
        if len(normalized) == 1 and ord(normalized[0]) == cp:
            continue

        offset = len(scalars)
        for scalar in normalized:
            scalars.append(ord(scalar))
        mappings.append((cp, offset, len(normalized)))

    return mappings, scalars, combining_entries


def main() -> None:
    mappings, scalars, combining_entries = build_tables()
    OUT_PATH.write_text(
        "\n".join(
            [
                "const std = @import(\"std\");",
                "",
                "pub const MappingEntry = struct {",
                "    cp: u32,",
                "    offset: u32,",
                "    len: u8,",
                "};",
                "",
                "pub const CombiningEntry = struct {",
                "    cp: u32,",
                "    ccc: u8,",
                "};",
                "",
                f"pub const unicode_version = \"{unicodedata.unidata_version}\";",
                "",
                "pub const mapping_entries = [_]MappingEntry{",
                format_mapping_array(mappings),
                "};",
                "",
                "pub const mapping_scalars = [_]u32{",
                format_u32_array(scalars),
                "};",
                "",
                "pub const combining_entries = [_]CombiningEntry{",
                format_struct_array(combining_entries),
                "};",
                "",
                "test \"generated nfkd tables are populated\" {",
                "    try std.testing.expect(mapping_entries.len > 0);",
                "    try std.testing.expect(mapping_scalars.len > 0);",
                "    try std.testing.expect(combining_entries.len > 0);",
                "}",
                "",
            ]
        )
    )


if __name__ == "__main__":
    main()
