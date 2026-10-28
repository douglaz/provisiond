#!/usr/bin/env python3
"""Fixture gate -- enforces WIR-37 and WIR-1a on every JSON example in the set.

WIR-37 says the examples are test inputs rather than illustrations:

    "Fixtures are complete and valid (CNF-176): every JSON example in this
     document parses under WIR-1a with real-shaped values -- full UUIDs,
     Z-suffixed timestamps, 64-hex digests -- so the examples are test inputs,
     not illustrations. Placeholder `...` inside an object is prohibited; where
     a sub-object is elided the example says so in prose outside the JSON."

WIR-1a fixes the JSON profile as I-JSON with bounded numbers:

    "A body MUST reject a duplicate object member at any depth (not last-wins),
     MUST be valid UTF-8, and every JSON number MUST be an integer within
     +/-(2^53-1) with no exponent or fraction."

It also structurally checks every ```mermaid block: a declared diagram type,
balanced brackets, balanced quotes. Mermaid renders on GitHub but there is no
offline parser here, so a broken diagram would look fine in source and fail in
the browser.

So this gate checks fenced ```json blocks and complete inline JSON containers:

  * it parses
  * it contains no duplicate object member at any depth
  * every number is an integer within +/-(2^53-1)
  * it contains no `...` placeholder
  * timestamps that look like RFC 3339 end in Z, never +00:00 (WIR-1)
  * sha256 fields are exactly 64 hex characters (DOM-14)
  * inventory device identity choices (RSC-46)

A fixture that fails here is a fixture an implementation cannot use, which is
the failure WIR-37 exists to prevent.

Exit status 0 = clean, 1 = failures.
"""

import glob
import json
import os
import re
import sys

try:
    from markdown_it import MarkdownIt
    from markdown_it.rules_block import lheading, paragraph
    from markdown_it.rules_inline import backtick, image
except ImportError as error:
    sys.exit(f"FAIL: inline Markdown parser dependency unavailable: {error}; run under nix develop")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAX_INT = 2 ** 53 - 1

FENCE_RE = re.compile(r"^```json\s*\n(.*?)^```", re.M | re.S)
TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(Z|[+-]\d{2}:\d{2})$")


def no_duplicate_keys(pairs):
    seen = {}
    for k, v in pairs:
        if k in seen:
            raise ValueError(f"duplicate object member {k!r}")
        seen[k] = v
    return seen


def check_inventory(node, path, problems):
    """RSC-46; wire byte equality only. No normalization or fingerprint work."""
    if not isinstance(node, dict) or not isinstance(node.get("devices"), list):
        problems.append(f"{path}: inventory needs a devices array (RSC-46)")
        return
    for i, device in enumerate(node["devices"]):
        where = f"{path}.devices[{i}]"
        if not isinstance(device, dict) or any(
            key not in device or (device[key] is not None and not isinstance(device[key], str))
            for key in ("identifier", "wwn", "serial")
        ):
            problems.append(f"{where}: identifier, wwn and serial must be strings or null (RSC-46)")
            continue
        expected = device["wwn"] if device["wwn"] is not None else device["serial"]
        if device["identifier"] != expected:
            problems.append(f"{where}.identifier: identity choice (RSC-46): "
                            f"expected {expected!r}, got {device['identifier']!r}")


def walk(node, path, problems):
    if isinstance(node, dict):
        for k, v in node.items():
            if k == "inventory":
                check_inventory(v, f"{path}.{k}", problems)
            walk(v, f"{path}.{k}", problems)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, f"{path}[{i}]", problems)
    elif isinstance(node, bool):
        pass
    elif isinstance(node, int):
        if abs(node) > MAX_INT:
            problems.append(f"{path}: integer {node} exceeds 2^53-1 (WIR-1a)")
    elif isinstance(node, float):
        problems.append(f"{path}: non-integer number {node} (WIR-1a)")
    elif isinstance(node, str):
        m = TS_RE.match(node)
        if m and m.group(1) != "Z":
            problems.append(f"{path}: timestamp {node!r} must end in Z (WIR-1)")
        if path.endswith(".sha256") and not re.fullmatch(r"[0-9a-fA-F]{64}", node):
            problems.append(f"{path}: sha256 must be exactly 64 hex chars (DOM-14)")


MERMAID_RE = re.compile(r"^```mermaid\s*\n(.*?)^```", re.M | re.S)
MERMAID_KINDS = (
    "flowchart", "graph", "sequenceDiagram", "stateDiagram-v2", "stateDiagram",
    "erDiagram", "classDiagram", "journey", "gantt", "pie", "mindmap", "timeline",
)


def check_mermaid():
    """A structural sanity check, not a parser.

    Mermaid renders on GitHub but there is no offline parser here, so a broken
    diagram would ship looking fine in source and fail in the browser. This
    catches the two errors that actually happen: a block that declares no
    diagram type, and unbalanced brackets or quotes in a label.
    """
    problems = 0
    count = 0
    for f in sorted(glob.glob("*.md")) + sorted(glob.glob("docs/adr/*.md")):
        text = open(f).read()
        for m in MERMAID_RE.finditer(text):
            count += 1
            line = text[: m.start()].count("\n") + 1
            body = m.group(1)
            first = next((l.strip() for l in body.splitlines() if l.strip()), "")
            if not first.startswith(MERMAID_KINDS):
                print(f"FAIL {f}:{line}: mermaid block declares no known diagram "
                      f"type (starts {first[:40]!r})")
                problems += 1
            # erDiagram's crow's-foot notation (||--o{, }o--o|) uses braces as
            # syntax rather than as pairs, so brace balance is meaningless there.
            pairs = [("[", "]"), ("(", ")")]
            if not first.startswith("erDiagram"):
                pairs.append(("{", "}"))
            for open_c, close_c in pairs:
                if body.count(open_c) != body.count(close_c):
                    print(f"FAIL {f}:{line}: unbalanced {open_c}{close_c} "
                          f"({body.count(open_c)} vs {body.count(close_c)})")
                    problems += 1
            if body.count('"') % 2:
                print(f"FAIL {f}:{line}: odd number of double quotes")
                problems += 1
    print(f"mermaid diagrams checked: {count} | failures: {problems}")
    return problems


STRING = r'"(?:[^"\\]|\\.)*"'
FIELD_SET_RE = re.compile(r"\{\s*" + STRING + r"(?:\s*,\s*" + STRING + r")*\s*\}", re.S)
UNQUOTED_FIELDS_RE = re.compile(r"\{\s*[A-Za-z_]\w*(?:\s*[,|]\s*[A-Za-z_]\w*)*\s*\}")
REQUIREMENT_RE = re.compile(r"^\*\*([A-Z]+-\d+[a-z]?)\*\*", re.M)

# These existing literal elisions are not complete inputs. Scope by source and
# owner as well as exact text; a placeholder in any complete input still fails.
INLINE_ELISIONS = {
    ("13-wire-contract.md", "WIR-43", '{"body": "..."}'),
    ("05-persistence.md", "STO-52", '{"operator_ref": "..."}'),
    ("docs/adr/0038-a-network-restriction-is-positive-evidence-from-either-source.md",
     None, '{"status": "restricted", "operator_ref": "..."}'),
}


def source_backtick(state, silent):
    """Let the parser select spans; retain its pre-render source range."""
    start = state.pos
    previous = state.tokens[-1] if state.tokens else None
    matched = backtick(state, silent)
    if matched and not silent and state.tokens and state.tokens[-1].type == "code_inline":
        token = state.tokens[-1]
        # An unmatched run emits pending text, not a new code token.
        if token is not previous:
            token.meta["source_range"] = (start, state.pos)
    return matched


def source_image(state, silent):
    # Image labels are parsed recursively with a sliced source string. Translate
    # their child positions back into the enclosing inline token's coordinates.
    start = state.pos
    matched = image(state, silent)
    if matched and not silent:
        def shift(tokens):
            for token in tokens:
                if "source_range" in token.meta:
                    a, b = token.meta["source_range"]
                    token.meta["source_range"] = (a + start + 2, b + start + 2)
                shift(token.children or [])
        shift(state.tokens[-1].children or [])
    return matched


def source_indentation(rule):
    def mapped_rule(state, start_line, end_line, silent):
        first = len(state.tokens)
        matched = rule(state, start_line, end_line, silent)
        if matched and not silent:
            for token in state.tokens[first:]:
                if token.type != "inline":
                    continue
                expansions = token.meta["tab_expansions"] = {}
                for row in range(*token.map):
                    raw = state.src[state.bMarks[row]:state.eMarks[row]]
                    content = state.getLines(row, row + 1, state.blkIndent, False)
                    if raw.endswith(content):
                        continue
                    # getLines can leave spaces from a partially consumed tab.
                    # Keep its transformation tied to that original character.
                    tail = 0
                    for a, b in zip(reversed(raw), reversed(content)):
                        if a != b:
                            break
                        tail += 1
                    padding = content[:len(content) - tail]
                    tab = state.eMarks[row] - tail - 1
                    if not (1 <= len(padding) <= 3 and padding == " " * len(padding)
                            and tab >= state.bMarks[row] and state.src[tab] == "\t"):
                        raise ValueError(f"unknown container indentation at line {row + 1}")
                    column = tab - (state.src.rfind("\n", 0, tab) + 1)
                    expansions[row] = (column, len(padding))
        return matched
    return mapped_rule


def inline_spans(text):
    """CommonMark + GFM tables select code; line maps recover original bytes.

    Inline token content retains line breaks but has container prefixes removed.
    Match each of its lines within the parser's source-line range, in cell order.
    Only tables remove backslashes before pipes; map those characters back too,
    so Markdown rendering cannot repair invalid JSON (including raw newlines).
    An unrecognized transformation is a mapping error, never a scanner fallback.
    """
    # The library's default nesting limit silently drops content. Let parsing
    # finish or raise an explicit error instead of accepting a partial document.
    parser = MarkdownIt("commonmark", {"maxNesting": sys.maxsize}).enable("table")
    parser.block.ruler.at("paragraph", source_indentation(paragraph))
    parser.block.ruler.at("lheading", source_indentation(lheading))
    parser.inline.ruler.at("backticks", source_backtick)
    parser.inline.ruler.at("image", source_image)
    tokens = parser.parse(text)
    lines = [m for m in re.finditer(r"[^\r\n]*(?:\r\n|\r|\n|$)", text) if m[0]]
    cursors = {}
    table_depth = 0

    for token in tokens:
        if token.type == "table_open":
            table_depth += 1
        elif token.type == "table_close":
            table_depth -= 1
        if token.type != "inline" or not token.content:
            continue
        if token.map is None:
            raise ValueError("inline token has no source-line map")
        offsets = []
        content_lines = token.content.split("\n")
        for i, content in enumerate(content_lines):
            row = token.map[0] + i
            if row >= token.map[1] or row >= len(lines):
                raise ValueError(f"inline token exceeds source-line map at line {row + 1}")
            raw = lines[row][0].rstrip("\r\n")
            positions = [j for j in range(len(raw))
                         if not (table_depth and raw[j] == "\\" and raw[j:j+2] == "\\|")]
            mapped = "".join(raw[j] for j in positions).replace("\0", "\ufffd")
            expansion = token.meta.get("tab_expansions", {}).get(row)
            if expansion:
                tab, width = expansion
                if tab >= len(raw) or raw[tab] != "\t" or table_depth:
                    raise ValueError(f"cannot map container tab at line {row + 1}")
                positions[tab:tab + 1] = [tab] * width
                mapped = mapped[:tab] + " " * width + mapped[tab + 1:]
            cursor = cursors.get(row, 0)
            column = mapped.find(content, cursor)
            if column < 0:
                raise ValueError(f"cannot map inline content at line {row + 1}: {content!r}")
            offsets.extend(lines[row].start() + j for j in positions[column:column + len(content)])
            cursors[row] = column + len(content)
            if i + 1 < len(content_lines):
                # The normalized newline points to the original line ending.
                offsets.append(lines[row].start() + len(raw))
        if len(offsets) != len(token.content):
            raise ValueError("inline source-map length mismatch")

        def spans(children):
            for child in children:
                if child.type == "code_inline":
                    if "source_range" not in child.meta:
                        raise ValueError("code span has no source range")
                    a, b = child.meta["source_range"]
                    delimiter = len(child.markup)
                    if not (0 <= a < b <= len(offsets)):
                        raise ValueError("code span exceeds inline source map")
                    body_start, body_end = a + delimiter, b - delimiter
                    pieces = []
                    position = body_start
                    while position < body_end:
                        newline = token.content.find("\n", position, body_end)
                        end = newline if newline >= 0 else body_end
                        if end > position:
                            pieces.append(text[offsets[position]:offsets[end - 1] + 1])
                        if newline >= 0:
                            ending = re.match(r"\r\n?|\n", text[offsets[newline]:])
                            if ending is None:
                                raise ValueError("code-span newline has no source ending")
                            pieces.append(ending[0])
                        position = end + 1
                    yield offsets[a], "".join(pieces)
                yield from spans(child.children or [])
        yield from spans(token.children or [])


def inline_fixtures(text, filename):
    for start, span in inline_spans(text):
        body = span.strip()
        # WIR-31 has an HTTP status before its complete JSON body.
        body = re.sub(r"^[1-5][0-9]{2}\s+(?=[{\[])", "", body)
        if not body.startswith(("{", "[")):
            continue  # field additions, scalar tokens and paths are not bodies
        # Recognize schema syntax before parsing; parse failure never skips input.
        if body.startswith("{"):
            if (UNQUOTED_FIELDS_RE.fullmatch(body)
                    or body == "{kind, external_id, billable, cleanup: api | manual}"
                    or body.startswith("{uppercase method}\\n")):
                continue  # field sets, path parameters and WIR-3's template
            tokens = re.sub(STRING, "STRING", body)
            if FIELD_SET_RE.fullmatch(body) or re.search(r"STRING(?:\s*\|\s*STRING)+", tokens):
                continue
            if re.fullmatch(r'\{\s*"limit_bytes"\s*:\s*nonnegative integer\s*\}', body):
                continue  # WIR-30's typed allowance notation
        elif re.fullmatch(r'\[[^\[\]{}"]+,[^\[\]{}"]+\)', body):
            continue  # half-open mathematical intervals
        elif re.fullmatch(r"\[(?:verify|design|observed)\]|\[\][A-Za-z_]\w*", body):
            continue  # annotations and types such as []string
        owners = list(REQUIREMENT_RE.finditer(text, 0, start))
        owner = owners[-1][1] if owners else None
        if (filename, owner, " ".join(body.split())) in INLINE_ELISIONS:
            continue
        yield start, body, owner


def validate_json(body):
    if "..." in body:
        return ["contains a `...` placeholder (WIR-37)"]
    try:
        doc = json.loads(body, object_pairs_hook=no_duplicate_keys)
    except ValueError as e:
        return [str(e)]
    problems = []
    walk(doc, "$", problems)
    return problems


def main():
    os.chdir(ROOT)
    mermaid_failures = check_mermaid()
    failures = 0
    blocks = 0
    inline_count = 0
    inventory_count = 0

    for f in sorted(glob.glob("*.md")) + sorted(glob.glob("docs/adr/*.md")):
        text = open(f).read()
        fixtures = []
        for i, m in enumerate(FENCE_RE.finditer(text), 1):
            fixtures.append((m.start(), m[1], f"json block {i}"))
        try:
            selected = list(inline_fixtures(text, f))
        except Exception as error:
            print(f"FAIL {f}: inline Markdown parser/source mapping: {error}")
            failures += 1
            selected = []  # report other files too; this file has already failed
        for start, body, owner in selected:
            inline_count += 1
            fixtures.append((start, body, f"inline JSON {owner or 'example'}"))
            if f == "13-wire-contract.md" and owner == "WIR-10b" and re.match(
                r'\{\s*"inventory"\s*:', body
            ):
                inventory_count += 1
        for start, body, label in fixtures:
            blocks += 1
            line = text[:start].count("\n") + 1
            for problem in validate_json(body):
                print(f"FAIL {f}:{line} ({label}): {problem}")
                failures += 1

    if inventory_count != 1:
        print("FAIL 13-wire-contract.md: WIR-10b mandatory inline inventory: "
              f"expected one selected example, found {inventory_count}")
        failures += 1
    else:
        print("WIR-10b mandatory inline inventory selected: 1")
    print(f"json fixtures checked: {blocks} (inline: {inline_count}) | failures: {failures}")
    return 1 if (failures or mermaid_failures) else 0


if __name__ == "__main__":
    sys.exit(main())
