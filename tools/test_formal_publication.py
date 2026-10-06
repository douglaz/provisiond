#!/usr/bin/env python3
"""Bounded tests of the real publisher, readers and full-gate dependency handling.

Run after successful formal generation. Only scripts and reader inputs enter the
small fixture; no repository or Lake build-tree copies. Socket handshakes hold
emitters after a flushed incomplete JSON line. Every child is waited/reaped.
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


def exercise(f):
    for emitter in ['gate', 'render']:
        f.overlap(emitter)
    for emitter, mode in [('gate', 'empty'), ('gate', 'partial'),
                          ('gate', 'complete'), ('render', 'partial')]:
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

    for command, target in [('mktemp', 'index'), ('mktemp', 'regions'),
                            ('mv', 'index'), ('mv', 'regions')]:
        real = shutil.which(command)
        shim = f.executable(command, '#!/usr/bin/env bash\n'
                            f'case "$*" in *{target}.jsonl*) echo "injected {command} failure" >&2; exit 74;; esac\n'
                            f'exec "{real}" "$@"\n')
        try:
            require(f.formal_run(), 1, f'injected {command} failure')
            f.unchanged()
        finally:
            shim.unlink()
        print(f'PASS: {command} {target} failure is red with private cleanup')

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
    else:
        main()
