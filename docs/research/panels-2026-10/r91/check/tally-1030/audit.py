from pathlib import Path
import ast, hashlib, importlib.util, json, re, subprocess, sys

sys.dont_write_bytecode = True
P = Path('/var/tmp/provisiond-panel-r91')
W = P / 'tmp/tally/verification'
O = P / 'check/tally-1030'
assert (W / 'results.json').exists(), 'required verifier must finish first'
sys.path.insert(0, str(W / 'N/tools'))
mods = {}
for kind in 'NABC':
    spec = importlib.util.spec_from_file_location('tally_' + kind, W / kind / 'tools/check_citations.py')
    m = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = m
    spec.loader.exec_module(m)
    mods[kind] = m

paths = ['tools/check_citations.py', '.github/workflows/ci.yml', '10-conformance-checklist.md']
base = P / 'sol'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=base, text=True).strip() == (P / 'PIN').read_text().strip()
assert (base / paths[0]).read_bytes() == (P / 'existing-checker.py').read_bytes()
proof = {}
def funcs(path):
    return {n.name: ast.dump(n, include_attributes=False) for n in ast.parse(path.read_text()).body if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef))}
original_functions = funcs(base / paths[0])
for kind in 'NABC':
    patch = (P / 'candidates' / kind / 'exact.patch').read_bytes()
    target = O / ('patch-check-' + kind)
    target.mkdir()
    for rel in paths:
        (target / rel).parent.mkdir(parents=True, exist_ok=True)
        (target / rel).write_bytes((base / rel).read_bytes())
    if patch:
        r = subprocess.run(['git', 'apply', '--unsafe-paths', '-'], input=patch, cwd=target, capture_output=True)
        assert r.returncode == 0, (kind, r.stderr)
    assert all((target / rel).read_bytes() == (P / 'candidates' / kind / rel).read_bytes() for rel in paths)
    current = funcs(target / paths[0])
    changed = [name for name, value in original_functions.items() if current.get(name) != value]
    assert all(current.get(name) == value for name, value in original_functions.items() if name.startswith('check_'))
    for name in ['contains_quote', 'corresponding_roles', 'span_content', 'find', 'exists']:
        assert current[name] == original_functions[name], (kind, name)
    proof[kind] = {'patch_sha256': hashlib.sha256(patch).hexdigest(), 'changed_existing_functions': changed, 'all_existing_self_tests_and_comparison_functions_identical': True}

records = json.loads((P / 'current-attributions.json').read_text())
chunks = json.loads((P / 'current-chunks.json').read_text())
for kind, m in mods.items():
    for row in records:
        chunk = chunks[row['chunk_id']]
        assert (row['quote_position_in_chunk'], row['quote']) in list(m.quotations(chunk['text'], max_length=400 if row['file'].endswith('.lean') else None)), (kind, row)
    proof[kind]['all_inventory_quote_slices_retained'] = True
(O / 'package-proof.json').write_text(json.dumps(proof, indent=2) + '\n')

rows = []
def cli(kind, label, relative, content):
    root = W / kind
    path = root / relative
    previous = path.read_bytes() if path.exists() else None
    try:
        path.write_text(content)
        r = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root, capture_output=True, text=True)
    finally:
        if previous is None: path.unlink()
        else: path.write_bytes(previous)
    (O / (kind + '-' + label + '.log')).write_text(r.stdout + r.stderr)
    row = {'form': kind, 'case': label, 'exit': r.returncode, 'diagnostics': [line for line in r.stdout.splitlines() if line.startswith('FAIL:') or 'attributes to ' in line or 'found in no document' in line]}
    rows.append(row)
    print(json.dumps(row), flush=True)
    return r

original = (base / '03-operation-lifecycle.md').read_text()
prefix = "with `API-63`'s “"
start = original.index(prefix)
opening = start + len(prefix) - 1
end = original.index('”', opening) + 1
quote = original[opening + 1:end - 1]
guard = 'API-63 straight quotation closes inside inline code;'
attr = 'attributes to API-63 a phrase API-63 does not contain'
for kind in 'NABC':
    # Reproduce the extraction advocate's complete reason: accepted original
    # punctuation and rejected nested-content corruption, without migration.
    for name, changed in [('valid', quote), ('reason', quote.replace('account_terminated', 'account_terminatd', 1))]:
        text = original[:start] + 'with `API-63` says "' + changed + '"' + original[end:]
        r = cli(kind, 'speech-' + name, '03-operation-lifecycle.md', text)
        expected = 1 if kind in 'AC' or (kind == 'B' and name != 'valid') else 0
        assert r.returncode == expected
        if expected: assert (guard if kind in 'AC' else attr) in r.stdout
    # Fable/Opus: a chunk cut in earlier inline code changes B's backtick pairs.
    head = original[:start].replace('fail `conflict`', 'fail `e.g. conflict`', 1)
    assert head != original[:start]
    wrong = quote.replace('account_terminated', 'account_terminatd', 1)
    r = cli(kind, 'earlier-code-cut', '03-operation-lifecycle.md', head + 'with `API-63`\'s "' + wrong + '"' + original[end:])
    assert r.returncode == (1 if kind in 'AC' else 0)
    if kind in 'AC': assert guard in r.stdout
    # All readers: A's additional wholly-inside-code rejection is absent in C.
    text = (W / kind / 'README.md').read_text() + '\n\n`API-63` says `"Recording a status the driver itself reports MUST be refused"`.\n'
    r = cli(kind, 'wholly-inside-code', 'README.md', text)
    assert r.returncode == (1 if kind == 'A' else 0)
    # Sol: extension crosses the unchanged Lean length cap, dropping an old
    # active corruption verdict. Use the exact pinned owner source slice.
    body = mods[kind].load()[2]['API-63'][1]
    left = body.index('`conflict`, with `details.reason: "account_terminated"`')
    right = body.index('below,', left) + len('below,')
    long = body[left:right]
    assert len(long) > 400
    for name, changed in [('valid', long), ('recoverable', long.replace('two recoverable', 'three recoverable', 1))]:
        r = cli(kind, 'long-' + name, 'tools/formal/TallyProbe.lean', '/-- `API-63` says "' + changed + '" -/\n')
        expected = 1 if kind in 'AC' or (kind == 'N' and name != 'valid') else 0
        assert r.returncode == expected
        if expected: assert (guard if kind in 'AC' else attr) in r.stdout
    # Opus: B additionally strengthens EXISTS at two current nested quotes.
    for relative, needle in [('tools/formal/Provisiond/Rescue.lean', '"MUST carry `rescue_exit: "unknown"`'), ('tools/formal/Provisiond/Witnesses.lean', '`rescue_exit: "unknown"` (`RSC-19`, `WIR-9a`)"')]:
        text = (W / kind / relative).read_text()
        assert text.count(needle) == 1
        changed = text.replace(needle, needle.replace('"unknown"', '"unknwn"'), 1)
        r = cli(kind, 'exists-' + Path(relative).stem, relative, changed)
        assert r.returncode == (1 if kind == 'B' else 0)
(O / 'adversarial-results.json').write_text(json.dumps(rows, indent=2) + '\n')
print('PASS: packages, inherited fixtures, current inventory and independent reader traces', flush=True)
