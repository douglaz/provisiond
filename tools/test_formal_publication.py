#!/usr/bin/env python3
"""Bounded tests of the real publisher, readers and full-gate dependency handling.

Run after successful formal generation. Only scripts and reader inputs enter the
small fixture; no repository or Lake build-tree copies. Socket handshakes hold
emitters after a flushed incomplete JSON line and renames before the foreground
shim returns. Every child is waited/reaped.
"""

import contextlib
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
TIMEOUT = 60


def lake():
    if sys.argv[2:] == ['build']:
        return
    assert sys.argv[2] == 'exe', sys.argv
    emitter = sys.argv[3]
    data = (Path(os.environ['SEED']) / f'{emitter}.jsonl').read_bytes()
    mode = os.environ.get('EMIT_MODE', 'success')
    fail = os.environ.get('FAIL_EMITTER') == emitter
    if fail and mode == 'empty':
        sys.exit(73)
    if os.environ.get('PAUSE_EMITTER') == emitter:
        sys.stdout.buffer.write(data[:1])
        sys.stdout.buffer.flush()
        with socket.socket(fileno=int(os.environ['HANDSHAKE'])) as channel:
            channel.settimeout(TIMEOUT)
            stat = os.fstat(1)
            channel.sendall(f'{stat.st_dev}:{stat.st_ino}\n'.encode())
            assert channel.recv(1) == b'G'
        if fail:
            sys.exit(73)
        sys.stdout.buffer.write(data[1:])
    else:
        sys.stdout.buffer.write(data[:1] if fail and mode == 'partial' else data)
    sys.stdout.buffer.flush()
    if fail:
        print(f'injected {emitter} {mode} failure', file=sys.stderr)
        sys.exit(73)


def run(args, *, cwd, env=None):
    with subprocess.Popen(args, cwd=cwd, env=env, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True,
                          stdin=subprocess.DEVNULL, start_new_session=True) as process:
        try:
            output, _ = process.communicate(timeout=TIMEOUT)
        except BaseException:
            os.killpg(process.pid, signal.SIGKILL)
            process.communicate()
            raise
        return process.returncode, output


def mv():
    source, destination = map(Path, sys.argv[-2:])
    if os.environ.get('FAIL_SECOND_RENAME') and destination.name == 'regions.jsonl':
        assert source.is_file(), 'unpublished regions temporary is missing'
        print('injected second rename failure', file=sys.stderr, flush=True)
        sys.exit(74)
    subprocess.run([os.environ['REAL_MV'], *sys.argv[2:]], check=True, timeout=TIMEOUT)
    if os.environ.get('PAUSE_RENAME') != destination.stem:
        return
    assert not source.exists() and destination.is_file(), 'real rename did not finish'
    print(f'renamed {destination.name}; shim has not returned', flush=True)
    with socket.socket(fileno=int(os.environ['HANDSHAKE'])) as channel:
        channel.settimeout(TIMEOUT)
        channel.sendall(str(source.resolve()).encode() + b'\n')
        assert channel.recv(1) == b'G'
    if os.environ.get('RENAME_SIGNAL'):
        os.kill(os.getppid(), int(os.environ['RENAME_SIGNAL']))
        sys.exit(int(os.environ.get('RENAME_STATUS', '0')))


def require(result, code=0, *messages):
    rc, output = result
    assert rc == code, (rc, code, output)
    for message in messages:
        assert message in output, (message, output)
    return output


class Fixture:
    def __init__(self, root):
        self.root = root
        self.tools = root / 'tools'
        self.formal = self.tools / 'formal'
        self.published = self.formal / '.lake'
        self.published.mkdir(parents=True)
        (self.formal / 'Provisiond').mkdir()
        (self.formal / 'Provisiond' / 'Probe.lean').write_text('-- fixture\n')
        (self.formal / 'Provisiond.lean').write_text('import Provisiond.Probe\n')
        for name in ['check_formal.sh', 'check_citations.py', 'check_regions.py',
                     'check_obligations.py']:
            shutil.copyfile(ROOT / 'tools' / name, self.tools / name)
        self.seed = root / 'seed'
        self.seed.mkdir()
        self.expected = {}
        for emitter, name in [('gate', 'index'), ('render', 'regions')]:
            data = (ROOT / 'tools/formal/.lake' / f'{name}.jsonl').read_bytes()
            assert data.startswith(b'{') and data.endswith(b'\n')
            for line in data.splitlines():
                json.loads(line)
            self.expected[name] = data
            (self.seed / f'{emitter}.jsonl').write_bytes(data)
        self.bin = root / 'bin'
        self.bin.mkdir()
        self.executable('lake', f'#!{sys.executable}\nimport runpy, sys\n'
                        f'sys.argv.insert(1, "--lake")\nrunpy.run_path({str(Path(__file__).resolve())!r}, run_name="__main__")\n')
        self.env = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                        SEED=str(self.seed), PYTHONDONTWRITEBYTECODE='1')
        self.serial = 0
        self.logs = {}
        self.reset()

    def executable(self, name, source):
        path = self.bin / name
        path.write_text(source)
        path.chmod(0o755)
        return path

    def reset(self):
        for name, data in self.expected.items():
            (self.published / f'{name}.jsonl').write_bytes(data)

    def unchanged(self):
        for name, data in self.expected.items():
            assert (self.published / f'{name}.jsonl').read_bytes() == data, name
        self.clean()

    def identities(self):
        return {name: (path.stat().st_dev, path.stat().st_ino)
                for name in self.expected
                for path in [self.published / f'{name}.jsonl']}

    def clean(self):
        assert sorted(p.name for p in self.published.iterdir()) == ['index.jsonl', 'regions.jsonl']

    def formal_run(self, **env):
        return run(['bash', 'tools/check_formal.sh'], cwd=self.root,
                   env=dict(self.env, **env))

    def reader(self, emitter):
        # These are the actual consumer entry points, with their normal paths.
        call = ('import check_citations as c; assert c.read_index()' if emitter == 'gate'
                else 'import check_regions as c; assert all(c.load_formal())')
        return run([sys.executable, '-c', f'import sys; sys.path.insert(0, "tools"); {call}'],
                   cwd=self.root, env=self.env)

    @contextlib.contextmanager
    def paused(self, emitter, **env):
        parent, child = socket.socketpair()
        parent.settimeout(TIMEOUT)
        self.serial += 1
        with (self.root / f'producer-{self.serial}.log').open('w+') as output:
            process = subprocess.Popen(
                ['bash', 'tools/check_formal.sh'], cwd=self.root,
                env=dict(self.env, PAUSE_EMITTER=emitter, HANDSHAKE=str(child.fileno()), **env),
                pass_fds=(child.fileno(),), stdout=output, stderr=output,
                stdin=subprocess.DEVNULL, start_new_session=True)
            self.logs[process.pid] = Path(output.name)
            child.close()
            try:
                ready = b''
                while not ready.endswith(b'\n'):
                    chunk = parent.recv(100)
                    assert chunk, 'producer exited before pause'
                    ready += chunk
                yield process, parent, ready
            finally:
                parent.close()
                if process.poll() is None:
                    os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=TIMEOUT)
                output.seek(0)
                log = output.read()
                if process.returncode != 0:
                    print(f'producer exit {process.returncode}: {log.strip()}')

    def finished(self, process, code=0, *messages):
        rc = process.wait(timeout=TIMEOUT)
        return require((rc, self.logs[process.pid].read_text()), code, *messages)

    def overlap(self, emitter, broken=False):
        self.reset()
        identities = self.identities()
        with self.paused(emitter) as (first, release_first, inode_first):
            with self.paused(emitter) as (second, release_second, inode_second):
                result = self.reader(emitter)
                if broken:
                    require(result, 1, 'JSONDecodeError',
                            'read_index' if emitter == 'gate' else 'load_formal')
                    name = 'index' if emitter == 'gate' else 'regions'
                    assert (self.published / f'{name}.jsonl').read_bytes() == b'{'
                else:
                    require(result)
                    assert inode_first != inode_second, 'producers share a temporary file'
                    assert self.identities() == identities, 'published before both emitters succeeded'
                    for name, data in self.expected.items():
                        assert (self.published / f'{name}.jsonl').read_bytes() == data
                # One producer publishes while the other remains paused.
                name = 'index' if emitter == 'gate' else 'regions'
                with (self.published / f'{name}.jsonl').open('rb') as old_reader:
                    release_first.sendall(b'G')
                    assert first.wait(timeout=TIMEOUT) == 0
                    if not broken:
                        assert old_reader.read() == self.expected[name]
                        assert self.identities()[name] != identities[name]
                if not broken:
                    require(self.reader(emitter))
                release_second.sendall(b'G')
                assert second.wait(timeout=TIMEOUT) == 0
        self.unchanged()
        print(f'PASS: {emitter} overlap: ' + ('direct writes cause the intended JSONDecodeError'
                                            if broken else 'distinct private files; readers see complete data'))


def reused_publication(f, fail_second=False, broken=False, signal_target=None):
    # Force reuse after a checked real rename, before the publisher can exit.
    # No random mktemp collision or timing-dependent second producer is needed.
    real = shutil.which('mv')
    assert real
    record = f.root / 'reused-names.jsonl'
    record.write_text('')
    replacement = b'another producer owns this file\n'
    shim = f.executable('mv', f'''#!{sys.executable}
import json, os, signal, subprocess, sys
from pathlib import Path
source, destination = map(Path, sys.argv[-2:])
if {fail_second!r} and destination.name == 'regions.jsonl':
    assert source.is_file(), 'unpublished regions temporary is missing'
    print('injected second rename failure', file=sys.stderr)
    sys.exit(74)
subprocess.run([{real!r}, *sys.argv[1:]], check=True, timeout={TIMEOUT})
with source.open('xb') as output:
    output.write({replacement!r})
with open({str(record)!r}, 'a') as log:
    log.write(json.dumps(str(source.resolve())) + '\\n')
if destination.stem == {signal_target!r}:
    print('injected SIGTERM after successful rename', flush=True)
    os.kill(os.getppid(), signal.SIGTERM)
''')
    reused = []
    try:
        result = f.formal_run()
        require(result, 143 if signal_target else 1 if fail_second else 0,
                'injected SIGTERM after successful rename' if signal_target else
                'injected second rename failure' if fail_second else 'regions:')
        reused = [Path(json.loads(line)) for line in record.read_text().splitlines()]
        expected = ['index'] if fail_second or signal_target == 'index' else ['index', 'regions']
        assert len(reused) == len(expected), (reused, result)
        for path, name in zip(reused, expected):
            assert path.parent == f.published.resolve() and path.name.startswith(f'{name}.jsonl.')
        missing = [path for path in reused if not path.exists()]
        if broken:
            deleted = [reused[-1]] if signal_target else reused
            assert missing == deleted, ('old cleanup did not delete the replacements', missing)
        else:
            assert not missing, ('cleanup deleted reused published temporary names', missing)
            for path in reused:
                assert path.read_bytes() == replacement, path
    finally:
        shim.unlink()
        for path in reused:
            path.unlink(missing_ok=True)
    # In the failure case this also requires cleanup of the unpublished regions file.
    f.unchanged()
    print(f'PASS: reused temporary names after {signal_target + " rename SIGTERM" if signal_target else "second rename failure" if fail_second else "normal exit"}: '
          + ('historical cleanup deleted another producer replacement (intended failure)'
             if broken else 'replacement files survive; unpublished files are cleaned'))


def reserved_publication(f, target, *, fail_second=False, sig=None, mv_status=0):
    # Pause after the actual rename, while the foreground mv shim is still alive.
    # A real second publisher allocates its own namespace and holds staged bytes.
    shim = f.executable('mv', f'#!{sys.executable}\nimport runpy, sys\n'
                        f'sys.argv.insert(1, "--mv")\nrunpy.run_path({str(Path(__file__).resolve())!r}, run_name="__main__")\n')
    sentinel = Path(tempfile.mkdtemp(prefix='publication.', dir=f.published))
    sentinel_file = sentinel / 'index.jsonl'
    sentinel_file.write_bytes(b'sibling staging sentinel\n')
    identities = f.identities()
    try:
        with f.paused('', PAUSE_RENAME=target, REAL_MV=shutil.which('mv'),
                      FAIL_SECOND_RENAME='1' if fail_second else '',
                      RENAME_SIGNAL=str(sig) if sig else '', RENAME_STATUS=str(mv_status)) as (first, release, ready):
            source = Path(ready.decode().strip())
            staging = source.parent
            assert staging.parent == f.published.resolve() and staging.is_dir(), 'staging directory was not reserved'
            assert source.name == f'{target}.jsonl' and not source.exists()
            assert (f.published / source.name).read_bytes() == f.expected[target]
            if target == 'index':
                assert (staging / 'regions.jsonl').read_bytes() == f.expected['regions']
            with f.paused('gate', REAL_MV=shutil.which('mv')) as (second, release_second, _):
                others = [p for p in f.published.iterdir() if p.is_dir() and p not in (staging, sentinel)]
                assert len(others) == 1, ('second publisher needs its own staging directory', others)
                second_staging = others[0]
                second_file = second_staging / 'index.jsonl'
                assert second_file.read_bytes() == b'{'
                release.sendall(b'G')
                f.finished(first, 128 + sig if sig else 1 if fail_second else 0,
                           f'renamed {target}.jsonl; shim has not returned',
                           'injected second rename failure' if fail_second else '')
                assert not staging.exists(), 'first producer leaked its staging directory/children'
                assert second_staging.is_dir() and second_file.read_bytes() == b'{', 'cleanup touched second producer'
                assert sentinel_file.read_bytes() == b'sibling staging sentinel\n', 'cleanup touched sibling sentinel'
                assert f.identities()['index'] != identities['index']
                if fail_second or (sig and target == 'index'):
                    assert f.identities()['regions'] == identities['regions']
                require(f.reader('gate'))
                require(f.reader('render'))
                release_second.sendall(b'G')
                f.finished(second, 0, 'regions:')
                assert not second_staging.exists(), 'second producer leaked staging'
    finally:
        shim.unlink()
        sentinel_file.unlink(missing_ok=True)
        sentinel.rmdir()
    f.unchanged()
    print(f'PASS: reserved directories at {target} rename, signal={sig}, mv_status={mv_status}, '
          f'fail_second={fail_second}: first cleaned; sibling sentinel and second producer survive and finish')


def exercise(f):
    for emitter in ['gate', 'render']:
        f.overlap(emitter)
    for emitter, mode in [(emitter, mode) for emitter in ['gate', 'render']
                          for mode in ['empty', 'partial', 'complete']]:
        identities = f.identities()
        require(f.formal_run(FAIL_EMITTER=emitter, EMIT_MODE=mode), 73)
        f.unchanged()
        assert f.identities() == identities, 'generation failure replaced published files'
        require(f.reader('gate'))
        require(f.reader('render'))
        print(f'PASS: {emitter} {mode} failure retains published bytes, cleans private files; standalone readers still pass')

    # Failure cleanup must not delete another producer's completed publication.
    with f.paused('gate', FAIL_EMITTER='gate') as (failed, release, _):
        require(f.formal_run())
        release.sendall(b'G')
        assert failed.wait(timeout=TIMEOUT) == 73
    f.unchanged()
    print('PASS: failed overlapping producer preserves successful publication')

    for command, target in [('mktemp', 'publication'), ('mv', 'index'), ('mv', 'regions')]:
        real = shutil.which(command)
        shim = f.executable(command, '#!/usr/bin/env bash\n'
                            f'case "$*" in *{target}.*)\n'
                            f'  echo "injected {command} failure" >&2\n'
                            '  [ -z "${SIGNAL_FAILED_RENAME:-}" ] || kill -TERM "$PPID"\n'
                            '  exit 74;; esac\n'
                            f'exec "{real}" "$@"\n')
        try:
            for terminate in [False, True] if command == 'mv' else [False]:
                require(f.formal_run(SIGNAL_FAILED_RENAME='1' if terminate else ''),
                        143 if terminate else 1, f'injected {command} failure',
                        'FAIL: could not allocate formal staging directory' if command == 'mktemp' else '')
                f.unchanged()
                print(f'PASS: {command} {target} failure, signal={terminate}: red with private cleanup')
        finally:
            shim.unlink()

    for target in ['index', 'regions']:
        reserved_publication(f, target)
        for sig in [signal.SIGHUP, signal.SIGINT, signal.SIGTERM]:
            reserved_publication(f, target, sig=sig)
        reserved_publication(f, target, sig=signal.SIGTERM, mv_status=74)
    reserved_publication(f, 'index', fail_second=True)

    with f.paused('gate') as (process, release, _):
        process.send_signal(signal.SIGTERM)
        release.sendall(b'G')
        assert process.wait(timeout=TIMEOUT) == 143
    f.unchanged()
    print('PASS: catchable termination cleans private output and retains publication')

    # A PATH containing dirname but no lake exercises the real missing-toolchain branch.
    empty_path = f.root / 'no-lake'
    empty_path.mkdir()
    (empty_path / 'dirname').symlink_to(shutil.which('dirname'))
    require(run([shutil.which('bash'), 'tools/check_formal.sh'], cwd=f.root,
                env=dict(f.env, PATH=str(empty_path))), 1, 'lake not on PATH')
    f.unchanged()
    for name in f.expected:
        (f.published / f'{name}.jsonl').unlink()
    for emitter in ['gate', 'render']:
        require(f.reader(emitter), 2, 'missing -- run tools/check_formal.sh first')
    require(f.formal_run(FAIL_EMITTER='gate', EMIT_MODE='partial'), 73)
    assert not list(f.published.iterdir())
    # Reach the missing-regions branch independently of the shared missing index.
    (f.published / 'index.jsonl').write_bytes(f.expected['index'])
    require(f.reader('render'), 2, 'regions.jsonl missing')
    require(f.formal_run())
    f.unchanged()
    print('PASS: missing toolchain and missing initial artifacts stay red; first success publishes')


def full_gate(f):
    # Execute the real full gate and all real document gates in the working tree.
    # The shim replays the exact preexisting artifacts; it never changes sources.
    calls = f.root / 'python-calls'
    shim = f.executable('python3', f'#!{sys.executable}\nimport os, sys\n'
                        f'with open({str(calls)!r}, "a") as log: log.write(sys.argv[1] + "\\n")\n'
                        f'os.execv({sys.executable!r}, [{sys.executable!r}, *sys.argv[1:]])\n')
    try:
        for fail in [True, False]:
            calls.write_text('')
            env = dict(f.env, FAIL_EMITTER='gate' if fail else '', EMIT_MODE='complete')
            result = run(['bash', 'tools/check-all.sh'], cwd=ROOT, env=env)
            output = require(result, 1 if fail else 0)
            invoked = calls.read_text().splitlines()
            for name in ['ids', 'fixtures', 'obligations', 'coverage']:
                assert f'tools/check_{name}.py' in invoked, (name, output)
            for name in ['citations', 'regions']:
                assert (f'tools/check_{name}.py' in invoked) == (not fail), output
                summary = [line for line in output.splitlines() if line.startswith('  PASS') or line.startswith('  FAIL')]
                assert any(('FAIL' if fail else 'PASS') in line and name in line for line in summary), output
                if fail:
                    assert any(name in line and 'blocked by formal failure (exit 73)' in line for line in output.splitlines()), output
                    assert not any('PASS' in line and name in line for line in summary), output
            if fail:
                for name in ['citations', 'regions']:
                    require(run([sys.executable, f'tools/check_{name}.py'], cwd=ROOT, env=f.env))
            for name, data in f.expected.items():
                assert (ROOT / 'tools/formal/.lake' / f'{name}.jsonl').read_bytes() == data
            print(f'PASS: real check-all {"failure blocks consumers; independent gates continue; standalone consumers pass retained output" if fail else "success invokes both consumers"}')
    finally:
        shim.unlink()


def negative_control(f):
    # Revert only the copied production publication tail; keep its preflight and
    # build logic. This is the historical direct-redirection path, not a toy writer.
    path = f.tools / 'check_formal.sh'
    original = path.read_bytes()
    prefix, separator, _ = original.partition(b'lake build || exit 1\n')
    assert separator
    old = b'''lake exe gate > .lake/index.jsonl
rc=$?
echo "index: $(wc -l < .lake/index.jsonl) tagged declarations -> tools/formal/.lake/index.jsonl"
[ "$rc" -eq 0 ] || exit "$rc"
lake exe render > .lake/regions.jsonl || exit 1
echo "regions: $(wc -l < .lake/regions.jsonl) marked regions -> tools/formal/.lake/regions.jsonl"
'''
    try:
        path.write_bytes(prefix + separator + old)
        for emitter in ['gate', 'render']:
            f.overlap(emitter, broken=True)
    finally:
        path.write_bytes(original)
        assert path.read_bytes() == original
    print('PASS: production script restored after direct-write negative controls')

    # Explicit historical tails: these controls must not depend on the current
    # publisher retaining flat-file variable names or ownership-release statements.
    flat = b'''index_tmp=
regions_tmp=
cleanup() {
  [ -z "$index_tmp" ] || rm -f "$index_tmp"
  [ -z "$regions_tmp" ] || rm -f "$regions_tmp"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
index_tmp=$(mktemp .lake/index.jsonl.XXXXXX) || exit 1
regions_tmp=$(mktemp .lake/regions.jsonl.XXXXXX) || exit 1
lake exe gate > "$index_tmp" || exit "$?"
lake exe render > "$regions_tmp" || exit "$?"
index_count=$(wc -l < "$index_tmp")
regions_count=$(wc -l < "$regions_tmp")
'''
    round1 = flat + b'''mv -f "$index_tmp" .lake/index.jsonl || exit 1
mv -f "$regions_tmp" .lake/regions.jsonl || exit 1
'''
    round2 = flat + b'''mv -f "$index_tmp" .lake/index.jsonl || exit 1
index_tmp=
mv -f "$regions_tmp" .lake/regions.jsonl || exit 1
regions_tmp=
'''
    counts = b'''echo "index: $index_count tagged declarations -> tools/formal/.lake/index.jsonl"
echo "regions: $regions_count marked regions -> tools/formal/.lake/regions.jsonl"
'''
    try:
        path.write_bytes(prefix + separator + round1 + counts)
        for fail_second in [False, True]:
            reused_publication(f, fail_second, broken=True)
        path.write_bytes(prefix + separator + round2 + counts)
        for fail_second in [False, True]:
            reused_publication(f, fail_second)
        for target in ['index', 'regions']:
            reused_publication(f, broken=True, signal_target=target)
    finally:
        path.write_bytes(original)
        assert path.read_bytes() == original
    print('PASS: production script restored after historical flat-staging cleanup controls')


def main():
    # /tmp may be RAM. Only this exact, owned temporary directory is removed.
    with tempfile.TemporaryDirectory(prefix='formal-publication-', dir='/var/tmp') as directory:
        print(f'fixture (removed on exit): {directory}', flush=True)
        f = Fixture(Path(directory))
        if sys.argv[1:] == ['--negative-control']:
            negative_control(f)
        else:
            assert not sys.argv[1:], sys.argv
            exercise(f)
            full_gate(f)


if __name__ == '__main__':
    if sys.argv[1:2] == ['--lake']:
        lake()
    elif sys.argv[1:2] == ['--mv']:
        mv()
    else:
        main()
