#!/usr/bin/env python3
"""End-to-end fixture-gate regressions. Scratch copies never mutate the source tree."""

import argparse
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
WIRE = "13-wire-contract.md"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--evidence-dir", type=Path)
    args = parser.parse_args()
    evidence = args.evidence_dir
    if evidence:
        evidence.mkdir(parents=True, exist_ok=True)
    sources = sorted(ROOT.glob("*.md")) + sorted((ROOT / "docs/adr").glob("*.md"))
    sources.append(ROOT / "tools/check_fixtures.py")
    original = {p: p.read_bytes() for p in sources}
    text = original[ROOT / WIRE].decode()
    section = text.split("**WIR-10b**", 1)[1].split("**WIR-11**", 1)[0]
    inventories = re.findall(r'`(\{"inventory":.*?)`', section, re.S)
    assert len(inventories) == 1, "test needs the live multiline inventory"
    inventory = inventories[0]
    assert "\n" in inventory
    doc = json.loads(inventory)
    line = text[:text.index("`" + inventory)].count("\n") + 1
    identity_where = f"FAIL {WIRE}:{line} (inline JSON WIR-10b): $.inventory.devices"
    cases = 0

    with tempfile.TemporaryDirectory(prefix="fixture-gate-", dir=evidence) as directory:
        scratch = Path(directory)
        for path, data in original.items():
            dest = scratch / path.relative_to(ROOT)
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(data)

        def check(name, source, code, diagnostic=None, failures=1, extra=None, changes=None):
            nonlocal cases
            (scratch / WIRE).write_text(source)
            probe = scratch / "fixture-probe.md"
            if extra is not None:
                probe.write_text(extra)
            elif probe.exists():
                probe.unlink()  # this runner created this exact scratch file
            command = [sys.executable, str(scratch / "tools/check_fixtures.py")]
            try:
                for filename, changed in (changes or {}).items():
                    (scratch / filename).write_text(changed)
                result = subprocess.run(command, capture_output=True, text=True)
            finally:
                for filename in changes or {}:
                    (scratch / filename).write_bytes(original[ROOT / filename])
            output = result.stdout + result.stderr
            if evidence:
                (evidence / f"{name}.log").write_text(output)
                (evidence / f"{name}.exit").write_text(f"{result.returncode}\n")
                (evidence / f"{name}.input.md").write_text(source)
                if extra is not None:
                    (evidence / f"{name}.probe.md").write_text(extra)
                for filename, changed in (changes or {}).items():
                    (evidence / f"{name}.{filename.replace('/', '-')}").write_text(changed)
                (evidence / f"{name}.command").write_text(f"cwd={ROOT}\n{command!r}\n")
            assert result.returncode == code, (name, result.returncode, output)
            assert not result.stderr, (name, result.stderr)
            failed = [s for s in result.stdout.splitlines() if s.startswith("FAIL ")]
            assert len(failed) == (failures if code else 0), (name, failed)
            if diagnostic:
                assert diagnostic in result.stdout, (name, diagnostic, output)
            if code == 0:
                assert "WIR-10b mandatory inline inventory selected: 1" in output
            print(f"PASS {name}: gate exit {result.returncode}")
            for failure in failed:
                print(f"  {failure}")
            cases += 1
            return output

        def replaced(body):
            assert text.count(inventory) == 1
            return text.replace(inventory, body, 1)

        def device_case(name, index, updates, code):
            changed = deepcopy(doc)
            changed["inventory"]["devices"][index].update(updates)
            check(name, replaced(json.dumps(changed, indent=2)), code,
                  identity_where + f"[{index}].identifier: identity choice (RSC-46):" if code else None)

        output = check("unchanged-live-inventory", text, 0)
        print(output, end="")
        device_case("valid-serial-only", 1, {"serial": "Serial-A", "identifier": "Serial-A"}, 0)
        device_case("valid-anonymous", 0, {"wwn": None, "serial": None, "identifier": None}, 0)
        device_case("anonymous-path-identifier", 1, {"identifier": "/dev/sda"}, 1)
        device_case("serial-mismatch", 1, {"serial": "Serial-A", "identifier": "different"}, 1)
        device_case("serial-null-identifier", 1, {"serial": "Serial-A", "identifier": None}, 1)
        device_case("serial-over-wwn", 0, {"identifier": "S4EVNF0N123456"}, 1)
        device_case("byte-equality-case", 0, {"identifier": "EUI.002538B111223344"}, 1)
        device_case("byte-equality-whitespace", 1, {"serial": " Serial-A ", "identifier": "Serial-A"}, 1)
        # Every device is checked, including beyond the first pair in the live example.
        changed = deepcopy(doc)
        changed["inventory"]["devices"].append({"wwn": None, "serial": "third", "identifier": None})
        check("third-device", replaced(json.dumps(changed)), 1,
              identity_where + "[2].identifier: identity choice (RSC-46):")
        changed = deepcopy(doc)
        del changed["inventory"]["devices"][1]["identifier"]
        check("missing-identity-field", replaced(json.dumps(changed)), 1,
              identity_where + "[1]: identifier, wwn and serial must be strings or null (RSC-46)")
        check("malformed-live-inline", replaced(inventory.replace('"devices": [', '"devices" [', 1)),
              1, f"FAIL {WIRE}:{line} (inline JSON WIR-10b): Expecting ':' delimiter")
        check("missing-mandatory-selection", replaced("inventory omitted"), 1,
              "WIR-10b mandatory inline inventory: expected one selected example, found 0")
        check("mandatory-moved-to-fence", replaced("inventory moved") + '\n```json\n' + inventory + '\n```\n',
              1, "WIR-10b mandatory inline inventory: expected one selected example, found 0")
        # General extraction, including a multiline span, an array, a second
        # backtick delimiter, literal pipes, and valid empty containers.
        general = check("general-inline-containers", text, 0, extra='''`{"value":
[{}, [], {"message": "on | off"}]}` and ``[{"n": 1}]`` and `[]` and `{}`.
Subobjects are omitted in prose; `{"machines": []}` is still complete.
''')
        inline_count = lambda output: int(re.search(r"\(inline: (\d+)\)", output)[1])
        assert inline_count(general) == inline_count(output) + 5
        baseline_count = inline_count(output)
        for context, opener, continuation in [
            ("unordered", "- ", "\t"),
            ("ordered", "1. ", "\t"),
            ("nested", "1. Parent\n    - ", "\t\t"),
            ("quoted", "> - ", "> \t"),
        ]:
            opening_line = opener.count("\n") + 1
            selected = check(f"{context}-prose-tab", text, 0,
                             extra=opener + "A paragraph\n" + continuation + "continued here.\n")
            assert inline_count(selected) == baseline_count
            for form, probe, source_line in [
                ("multiline", opener + '`{"ok":\n' + continuation + 'VALUE}`\n', opening_line),
                ("later-line", opener + 'a\n' + continuation + '`{"ok": VALUE}`\n', opening_line + 1),
                ("setext", opener + '`{"ok":\n' + continuation + 'VALUE}`\n'
                 + continuation + '===\n', opening_line),
            ]:
                for valid in (True, False):
                    selected = check(f'{context}-{form}-tab-{"valid" if valid else "invalid"}',
                                     text, 0 if valid else 1,
                                     None if valid else f'FAIL fixture-probe.md:{source_line} '
                                     '(inline JSON example): Expecting value',
                                     extra=probe.replace('VALUE', 'true' if valid else ''))
                    assert inline_count(selected) == baseline_count + 1
            for name, body in [
                ("literal-tab", '{"message":\n' + continuation + '"raw\tdata"}'),
                ("raw-newline", '{"message": "raw\n' + continuation + 'data"}'),
            ]:
                selected = check(f"{context}-{name}-in-string", text, 1,
                                 f'FAIL fixture-probe.md:{opening_line} '
                                 '(inline JSON example): Invalid control character',
                                 extra=opener + '`' + body + '`\n')
                assert inline_count(selected) == baseline_count + 1
            selected = check(f"{context}-tab-owner", text, 1,
                             f'FAIL fixture-probe.md:{opening_line + 3} '
                             '(inline JSON TST-1): Expecting value',
                             extra='**TST-1** A requirement\n\n' + opener + 'a\n'
                             + continuation + '`{"ok": }`\n')
            assert inline_count(selected) == baseline_count + 1
        selected = check("valid-inline-spaces", text, 0, extra='- `{"ok":\n    true}`\n')
        assert inline_count(selected) == baseline_count + 1
        # Parser-selected block boundaries and container continuations. Each
        # valid counterpart proves selection independently of the exit status.
        for name, probe, source_line in [
            ("mixed-inline", '- > `{"bad":\n  > VALUE}`\n', 1),
            ("nested-quote-boundary", '1. Parent\n    - Para `stray\n      > Text `{"bad": VALUE}`\n', 3),
            ("setext", 'Heading `stray\n===\nText `{"bad": VALUE}`\n', 3),
            ("lazy-quote", '> Body `{"bad":\nVALUE}`\n', 1),
            ("gfm-table", '| a `stray | b |\n|---|---|\n| `{"bad": VALUE}` | c |\n', 3),
            ("deep-quote", '> ' * 30 + '`{"bad": VALUE}`\n', 1),
        ]:
            for valid in (True, False):
                selected = check(f'{name}-{"valid" if valid else "invalid"}', text,
                                 0 if valid else 1,
                                 None if valid else f'FAIL fixture-probe.md:{source_line} '
                                 '(inline JSON example): Expecting value',
                                 extra=probe.replace('VALUE', 'true' if valid else ''))
                assert inline_count(selected) == baseline_count + 1
        for name, probe in [
            ("mixed-fence-closed", '- > ```text\n  > `{"bad": }`\n  > ```\n'),
            ("mixed-fence-eof", '- > ```text\n  > `{"bad": }`\n'),
            ("tab-fence-closed", '-\t```text\n\t`{"bad": }`\n\t```\n'),
            ("tab-fence-eof", '-\t```text\n\t`{"bad": }`\n'),
            ("lazy-quote-false-positive", '> Quote `stray\nText `{"bad": }`\n'),
            ("indented-code", 'Para\n\n    `{"bad": }`\n'),
            ("html-block", '<div>\n`{"bad": }`\n</div>\n'),
        ]:
            selected = check(name, text, 0, extra=probe)
            assert inline_count(selected) == baseline_count
        for valid in (True, False):
            selected = check(f'later-line-owner-{"valid" if valid else "invalid"}', text,
                             0 if valid else 1,
                             None if valid else 'FAIL fixture-probe.md:3 '
                             '(inline JSON TST-1): Expecting value',
                             extra='**TST-1** A paragraph\nwith another line\nand `{"ok": '
                             + ('true' if valid else '') + '}`.\n')
            assert inline_count(selected) == baseline_count + 1
        for name, body, code, diagnostic in [
            ("raw-newline-in-string", '{"message": "raw\nnewline"}', 1, 'Invalid control character'),
            ("escaped-newline-in-string", r'{"message": "raw\nnewline"}', 0, None),
            ("table-raw-escape", r'{"message": "a\|b"}', 1, 'Invalid \\escape'),
            ("table-valid-escape", r'{"message": "a\\|b"}', 0, None),
            ("nul-in-string", '{"message": "a\0b"}', 1, 'Invalid control character'),
        ]:
            probe = ('| value |\n|---|\n| `' + body + '` |\n' if name.startswith('table-')
                     else '**TST-1** A paragraph\nwith another line\nand `' + body + '`.\n')
            selected = check(name, text, code,
                             'FAIL fixture-probe.md:3 (inline JSON '
                             + ('example' if name.startswith('table-') else 'TST-1')
                             + '): ' + diagnostic if diagnostic else None, extra=probe)
            assert inline_count(selected) == baseline_count + 1
        for name, probe in [
            ("image-label", '![`BODY`](image.png)\n'),
            ("nested-image-label", '![![`BODY`](inner.png)](outer.png)\n'),
            ("link-label", '[`BODY`](https://example.test)\n'),
            ("duplicate-table-cells", '| `BODY` | `BODY` |\n|---|---|\n'),
            ("unmatched-after-code", '`BODY` ``unmatched\n'),
        ]:
            for valid in (True, False):
                body = '{"ok": true}' if valid else '{"bad": }'
                expected = probe.count('BODY')
                selected = check(f'{name}-{"valid" if valid else "invalid"}', text,
                                 0 if valid else 1,
                                 None if valid else 'FAIL fixture-probe.md:1 '
                                 '(inline JSON example): Expecting value', failures=expected,
                                 extra=probe.replace('BODY', body))
                assert inline_count(selected) == baseline_count + expected
        # A delimiter in another block cannot consume this complete example.
        for boundary, prefix, line_number, continuation in [
            ("nested-item", '1. Parent\n    1. Literal \\\\`field\\\\``\n    2. Body ', 3, '       '),
            ("heading", 'Para `stray\n# Heading\nText ', 3, ''),
            ("blockquote", 'Para `stray\n> Text ', 2, '> '),
            ("thematic-break", 'Para `stray\n***\nText ', 3, ''),
        ]:
            for valid in (True, False):
                body = '{"ok": true}' if valid else '{"bad": }'
                selected = check(f'block-boundary-{boundary}-{"valid" if valid else "invalid"}',
                                 text, 0 if valid else 1,
                                 None if valid else f'FAIL fixture-probe.md:{line_number} '
                                 '(inline JSON example): Expecting value',
                                 extra=prefix + '`' + body + '`.\n')
                assert inline_count(selected) == baseline_count + 1
            selected = check(f'block-boundary-{boundary}-multiline', text, 0,
                             extra=prefix + '`{"ok":\n' + continuation + 'true}`.\n')
            assert inline_count(selected) == baseline_count + 1
        # Backticks in a putative fence's info string make these inline spans.
        triple = '```{"n": 1.5}```\n\n```{"ok": true}```\n'
        selected = check("triple-delimiter-invalid", text, 1,
                         'FAIL fixture-probe.md:1 (inline JSON example): $.n: non-integer number 1.5 (WIR-1a)',
                         extra=triple)
        assert inline_count(selected) == baseline_count + 2
        selected = check("triple-delimiter-valid", text, 0, extra=triple.replace('1.5', '1'))
        assert inline_count(selected) == baseline_count + 2
        # Escapes apply outside code spans, including backslash parity. Inside
        # spans a backslash is literal and cannot escape the closing delimiter.
        for name, prefix, suffix, body, code, diagnostic in [
            ("escaped-outside-invalid", r'\`outside', r'\`outside', '{"bad": }', 1, 'Expecting value'),
            ("escaped-outside-valid", r'\`outside', r'\`outside', '{"ok": true}', 0, None),
            ("literal-backslash-closing", r'`\` and ', '', '{"bad": }', 1, 'Expecting value'),
        ]:
            selected = check(name, text, code, diagnostic, extra=prefix + '\n`' + body + '`\n' + suffix + '\n')
            assert inline_count(selected) == baseline_count + 1
            if code:
                assert 'FAIL fixture-probe.md:2 (inline JSON example):' in selected
        selected = check("odd-backslashes-escape", text, 0, extra=r'\\\`{"ignored": }\\\`' + '\n')
        assert inline_count(selected) == baseline_count
        selected = check("even-backslashes", text, 0, extra=r'\\`{"ok": true}`' + '\n')
        assert inline_count(selected) == baseline_count + 1
        selected = check("backslash-before-embedded-backtick", text, 1,
                         '$.n: non-integer number 1.5 (WIR-1a)',
                         extra=r'``{"message": "\\`", "n": 1.5}``' + '\n')
        assert inline_count(selected) == baseline_count + 1
        selected = check("multiline-multiple-backticks", text, 0,
                         extra='``{"message": "a ` backtick",\n"ok": true}``\n')
        assert inline_count(selected) == baseline_count + 1
        provider_file = "08-provider-notes.md"
        provider = original[ROOT / provider_file].decode()
        provider_lines = provider.splitlines(keepends=True)
        paragraph = '\nA complete body `{"bad": }` must be checked.\n\n'
        # Match the review reproduction's insertion after source line 420,
        # between the real escaped delimiters, without editing the live source.
        changed = ''.join(provider_lines[:420]) + paragraph + ''.join(provider_lines[420:])
        selected = check("real-provider-escaped-region", text, 1,
                         'FAIL 08-provider-notes.md:422 (inline JSON example): Expecting value',
                         changes={provider_file: changed})
        assert inline_count(selected) == baseline_count + 1
        api_file = "04-api-contract.md"
        api = original[ROOT / api_file].decode()
        literal = r'`\`'
        assert api.count(literal) == 1
        changed = api.replace(literal, literal + ' and `{"bad": }`', 1)
        api_line = api[:api.index(literal)].count('\n') + 1
        selected = check("real-api-literal-backslash", text, 1,
                         f'FAIL {api_file}:{api_line} (inline JSON API-2): Expecting value',
                         changes={api_file: changed})
        assert inline_count(selected) == baseline_count + 1
        selected = check("unmatched-span-before-paragraph", text, 1, 'Expecting value',
                         extra='``unmatched\n \t\nA complete body `{"bad": }` must be checked.\n')
        assert 'FAIL fixture-probe.md:3 (inline JSON example):' in selected
        assert inline_count(selected) == baseline_count + 1
        contract_file = "02-provider-contract.md"
        contract = original[ROOT / contract_file].decode()
        # The escaped delimiters in PRV-32 item 1 leave a stray backtick;
        # it must not pair with a delimiter in item 2.
        password = 'versus `Password`)'
        assert contract.count(password) == 1
        password_line = contract[:contract.index(password)].count('\n') + 1
        for name, body, code in [
            ("real-list-item-valid", '{"ok": true}', 0),
            ("real-list-item-invalid", '{"bad": }', 1),
        ]:
            changed = contract.replace(password, 'versus `' + body + '`)', 1)
            selected = check(name, text, code,
                             f'FAIL {contract_file}:{password_line} (inline JSON PRV-32): Expecting value'
                             if code else None, changes={contract_file: changed})
            assert inline_count(selected) == baseline_count + 1
        for marker_name, marker in [('ordered-dot', '2.'), ('ordered-paren', '2)'),
                                    ('dash', '-'), ('plus', '+'), ('star', '*'),
                                    ('indented', '   -')]:
            for valid in (True, False):
                body = '{"ok":\n   true}' if valid else '{"bad": }'
                probe = '1. Literal \\`field\\``\n' + marker + ' Body `' + body + '`.\n'
                selected = check(f'list-boundary-{marker_name}-{"valid" if valid else "invalid"}',
                                 text, 0 if valid else 1,
                                 None if valid else 'FAIL fixture-probe.md:2 (inline JSON example): Expecting value',
                                 extra=probe)
                assert inline_count(selected) == baseline_count + 1
        # This previously selected real example must stay covered when delimiter
        # handling changes elsewhere in its source document.
        error_body = '{"error":{"code":"NOT_FOUND","message":"no transactions found"}}'
        assert contract.count(error_body) == 1
        changed = contract.replace(error_body, error_body.replace('"no transactions found"', ''), 1)
        error_line = contract[:contract.index(error_body)].count('\n') + 1
        selected = check("existing-provider-error-still-selected", text, 1,
                         f'FAIL {contract_file}:{error_line} (inline JSON PRV-39): Expecting value',
                         changes={contract_file: changed})
        assert inline_count(selected) == baseline_count
        for name, body, diagnostic in [
            ("malformed-general-inline", '{"value": }', "Expecting value"),
            ("unquoted-key", '{bad: 1}', "double quotes"),
            ("single-quoted-key", "{'bad': 1}", "double quotes"),
            ("duplicate-key", '{"outer": {"x": 1, "x": 2}}', "duplicate object member 'x'"),
            ("bounded-integer", '{"n": 9007199254740992}', "integer 9007199254740992 exceeds 2^53-1 (WIR-1a)"),
            ("fraction", '{"n": 1.5}', "non-integer number 1.5 (WIR-1a)"),
            ("exponent", '{"n": 1e2}', "non-integer number 100.0 (WIR-1a)"),
            ("nonfinite", '{"n": NaN}', "non-integer number nan (WIR-1a)"),
            ("nonfinite-array", '[NaN]', "non-integer number nan (WIR-1a)"),
            ("timestamp", '{"at": "2026-10-28T01:00:00+00:00"}', "must end in Z (WIR-1)"),
            ("digest", '{"source": {"sha256": "bad"}}', "sha256 must be exactly 64 hex chars (DOM-14)"),
            ("placeholder", '{"complete": "..."}', "contains a `...` placeholder (WIR-37)"),
            ("literal-pipe-invalid", '{"message": "on | off", "n": 1.5}', "non-integer number 1.5 (WIR-1a)"),
        ]:
            output = check(name, text, 1, "FAIL fixture-probe.md:1 (inline JSON example):", extra=f"`{body}`\n")
            assert diagnostic in output, (name, output)
        # Keep explicit schema/elision selection assertions independent of a green
        # corpus run: adding a broken complete object beside notation must fail.
        fragments = '''`{"status": "pending" | "active" | "suspended"}`
`{"action": "on" | "off" | "reboot" |
"hard_reset"}` and `{"status", "source", "observed_at"}`
`"credits": [{"amount_sats": 250000}]` and `"expired": false`
`{ "limit_bytes": nonnegative integer }` and `{check, because}`
`[verify]` and `[0,1)` and `[]string`
'''
        check("schema-fragments", text, 0, extra=fragments)
        check("broken-beside-schema", text, 1, "Expecting value", extra=fragments + '`{"value": }`\n')
        # The current WIR-43 elision stays out; other placeholders under that owner do not.
        submission = '`{"body": "..."}`'
        assert text.count(submission) == 1
        check("elision-is-exact", text.replace(submission, submission + ' and `{"other": "..."}`'),
              1, "(inline JSON WIR-43): contains a `...` placeholder (WIR-37)")
        for name, body, diagnostic in [
            ("fenced-json", '```json\n{"x": 1, "x": 2}\n```\n', "(json block 1): duplicate object member 'x'"),
            ("mermaid", '```mermaid\nflowchart LR\nA[broken\n```\n', "unbalanced [] (1 vs 0)"),
        ]:
            check(name, text, 1, diagnostic, extra=body)
        check("non-json-fences", text, 0, extra='```text\n`{"bad": }`\n```\n~~~text\n`{"bad": }`\n~~~\n')
        selected = check("longer-fence-closers", text, 0,
                         extra='   ````text\n```{"bad": }```\n   `````\n'
                               '~~~text `info`\n`{"bad": }`\n~~~~\n')
        assert inline_count(selected) == baseline_count
        # Without a closer, a real non-JSON fence owns the rest of the file.
        # A short, wrong-kind or text-suffixed delimiter cannot close it.
        for name, probe in [
            ("eof-backtick-fence", '```text\n`{"bad": }`\n'),
            ("eof-tilde-fence", '~~~text\n`{"bad": }`\n'),
            ("eof-short-closer", '````text\n```\n`{"bad": }`\n'),
            ("eof-wrong-closer", '```text\n~~~\n`{"bad": }`\n'),
            ("eof-text-after-closer", '```text\n``` trailing\n`{"bad": }`\n'),
        ]:
            selected = check(name, text, 0, extra=probe)
            assert inline_count(selected) == baseline_count
        selected = check("closed-fence-followed-by-inline", text, 1,
                         'FAIL fixture-probe.md:4 (inline JSON example): Expecting value',
                         extra='```text\n`{"ignored": }`\n````\n`{"bad": }`\n')
        assert inline_count(selected) == baseline_count + 1
        selected = check("fence-content-container-markers-are-literal", text, 0,
                         extra='```text\n> `{"bad": }`\n```\n'
                               '- ```text\n  > `{"bad": }`\n  - `{"bad": }`\n'
                               '  # `{"bad": }`\n  ```\n')
        assert inline_count(selected) == baseline_count
        for container, opener, indentation in [
            ("list", '- ', '  '),
            ("nested-list", '1. Parent\n    - ', '      '),
        ]:
            for kind, delimiter in [('backtick', '```'), ('tilde', '~~~')]:
                fenced = opener + delimiter + 'text\n' + indentation + '`{"bad": }`\n'
                for ending, suffix in [('eof', ''), ('closed', indentation + delimiter + '\n')]:
                    selected = check(f'{container}-{kind}-fence-{ending}', text, 0,
                                     extra=fenced + suffix)
                    assert inline_count(selected) == baseline_count
                closed = fenced + indentation + delimiter + delimiter[0] + '\n'
                for ending, probe in [
                    ('after-closer', closed + indentation + '`{"bad": }`\n'),
                    ('after-container', fenced + '\n`{"bad": }`\n'),
                    ('sibling-item', fenced + opener.splitlines()[-1] + '`{"bad": }`\n'),
                ]:
                    source_line = probe.count('\n')
                    selected = check(f'{container}-{kind}-fence-{ending}', text, 1,
                                     f'FAIL fixture-probe.md:{source_line} (inline JSON example): Expecting value',
                                     extra=probe)
                    assert inline_count(selected) == baseline_count + 1
        check("restored-corpus", text, 0)

        # A parser or source-map defect must turn the gate red explicitly. Inject
        # faults in the copied checker, never in the live corpus or dependency.
        checker = original[ROOT / 'tools/check_fixtures.py'].decode()
        for name, before, after, diagnostic in [
            ('parser-error', 'tokens = parser.parse(text)',
             'tokens = parser.parse(text)\n    if text.startswith("Fault probe"):\n'
             '        raise RuntimeError("injected parser failure")', 'injected parser failure'),
            ('mapping-error', 'if token.map is None:',
             'if token.map is None or text.startswith("Fault probe"):',
             'inline token has no source-line map'),
        ]:
            assert checker.count(before) == 1
            check(name, text, 1,
                  f'inline Markdown parser/source mapping: {diagnostic}',
                  extra='Fault probe `{"ok": true}`\n',
                  changes={'tools/check_fixtures.py': checker.replace(before, after, 1)})
        command = [sys.executable, '-S', str(scratch / 'tools/check_fixtures.py')]
        result = subprocess.run(command, capture_output=True, text=True)
        diagnostic = 'FAIL: inline Markdown parser dependency unavailable:'
        assert result.returncode == 1 and diagnostic in result.stderr, result
        assert 'Traceback' not in result.stderr and not result.stdout, result
        if evidence:
            (evidence / 'missing-dependency.command').write_text(repr(command) + '\n')
            (evidence / 'missing-dependency.log').write_text(result.stderr)
            (evidence / 'missing-dependency.exit').write_text(f'{result.returncode}\n')
        cases += 1
        print('PASS missing-dependency: gate exit 1 with explicit dependency diagnostic')

    for path, data in original.items():
        assert path.read_bytes() == data, f"source changed: {path}"
    restoration = "\n".join(f"{hashlib.sha256(data).hexdigest()}  {p.relative_to(ROOT)}" for p, data in original.items()) + "\n"
    if evidence:
        (evidence / "source-restoration.sha256").write_text(restoration)
    print(f"PASS source restoration: all copied source bytes unchanged; {cases} named gate cases")
    return 0


if __name__ == "__main__":
    sys.exit(main())
