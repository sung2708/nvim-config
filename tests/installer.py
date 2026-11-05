"""Exercise the Unix installer without package installs or changing the real home."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'bin/install.sh'


class InstallerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='nvim install ')
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.tools = self.home / 'mock-bin'
        self.tools.mkdir()
        self.log = self.home / 'calls'
        self.env = dict(os.environ, HOME=str(self.home), SHELL='/bin/bash',
                        PATH=f'{self.tools}:/usr/bin:/bin', XDG_CONFIG_HOME=str(self.home / 'config'),
                        XDG_DATA_HOME=str(self.home / 'data'), MOCK_ROOT=str(self.home),
                        MOCK_LOG=str(self.log), MOCK_OS='Darwin', MOCK_ARCH='arm64')
        self.stub('id', 'echo 1000')
        self.stub('uname', 'if [[ $1 == -s ]]; then echo "$MOCK_OS"; else echo "$MOCK_ARCH"; fi')
        self.stub('brew', '''if [[ $1 == --prefix ]]; then
    case "${2:-}" in
      node@24) echo "$MOCK_ROOT/node" ;;
      python@3.13) echo "$MOCK_ROOT/python" ;;
      openjdk@25) echo "$MOCK_ROOT/java" ;;
      *) echo "$MOCK_ROOT/brew" ;;
    esac
fi''')
        self.stub('git', '''if [[ $1 == clone ]]; then
    [[ ${MOCK_FAIL_CLONE:-0} == 0 ]] || exit 1
    mkdir -p "$3/bin" "$3/.git"
    echo '-- fixture' > "$3/bin/bootstrap.lua"
elif [[ $1 == -C ]]; then
    echo https://github.com/sung2708/nvim-config.git
fi''')
        self.stub('npm', 'mkdir -p "$3/node_modules/.bin"')
        self.stub('python3', '''mkdir -p "$3/bin"
printf '#!/bin/sh\nexit 0\n' > "$3/bin/python"
chmod +x "$3/bin/python"''')
        self.stub('nvim', '[[ ${MOCK_FAIL_NVIM:-0} == 0 ]]')
        self.stub('sudo', '"$@"')
        for command in ['apt-get', 'dnf', 'pacman']:
            self.stub(command, 'exit 0')

    def stub(self, name, body):
        path = self.tools / name
        path.write_text('#!/bin/bash\nprintf "%s %s\\n" "${0##*/}" "$*" >> "$MOCK_LOG"\n' + body + '\n')
        path.chmod(0o755)

    def install(self, **env):
        return subprocess.run(['/bin/bash', str(SCRIPT)], env=dict(self.env, **env),
                              capture_output=True, text=True)

    def test_backup_retry_and_shell_path(self):
        config = self.home / 'config/nvim'
        config.mkdir(parents=True)
        (config / 'init.lua').write_text('keep my config')
        result = self.install()
        self.assertEqual(result.returncode, 0, result.stderr)
        backups = list(config.parent.glob('nvim.backup-*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / 'init.lua').read_text(), 'keep my config')
        profile = (self.home / '.bashrc').read_text()
        subprocess.run(['/bin/bash', '-n'], input=profile, text=True, check=True)
        self.assertIn('/brew/bin/brew', profile)
        self.assertIn('shellenv', profile)
        self.assertEqual(self.install().returncode, 0)
        self.assertEqual((self.home / '.bashrc').read_text(), profile)
        self.assertEqual(len(list(config.parent.glob('nvim.backup-*'))), 1)
        self.assertEqual(self.log.read_text().count('git clone'), 1)
        self.assertEqual(self.log.read_text().count('nvim --headless'), 4)

    def test_failed_clone_preserves_config(self):
        config = self.home / 'config/nvim'
        config.mkdir(parents=True)
        (config / 'init.lua').write_text('unchanged')
        self.assertNotEqual(self.install(MOCK_FAIL_CLONE='1').returncode, 0)
        self.assertEqual((config / 'init.lua').read_text(), 'unchanged')
        self.assertFalse(list(config.parent.glob('nvim.backup-*')))
        self.assertFalse(list(config.parent.glob('nvim-install.*')))

    def test_runtime_failure_is_not_success(self):
        self.assertNotEqual(self.install(MOCK_FAIL_NVIM='1').returncode, 0)

    def test_linux_dependencies_and_unsupported_platform(self):
        result = self.install(MOCK_OS='Linux', MOCK_ARCH='x86_64')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('apt-get install', self.log.read_text())
        for previous, manager in [('apt-get', 'dnf'), ('dnf', 'pacman')]:
            (self.tools / previous).unlink()
            result = self.install(MOCK_OS='Linux', MOCK_ARCH='aarch64')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn(manager + ' ', self.log.read_text())
        self.assertNotEqual(self.install(MOCK_OS='FreeBSD').returncode, 0)


if __name__ == '__main__':
    unittest.main()
